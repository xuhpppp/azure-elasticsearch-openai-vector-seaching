from fastapi import FastAPI, Depends, APIRouter
from openai import OpenAI
import os
from sqlalchemy.orm import Session
from db import db_connect, es_client, ELASTICSEARCH_INDEX
from models import Medicine
from storageQueue import queue_connect
from request import MedicineCreate


openai_client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
EMBEDDING_MODEL = "text-embedding-3-small"
NUMBER_OF_DIMENSIONS = 1408


# connect to MySQL db
SessionLocal = db_connect()


# dependency to get the database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# connect to Azure Storage Queue
queue_client = queue_connect()


app = FastAPI()
medicine_router = APIRouter(prefix="/search")


# health check endpoint
@medicine_router.get("/health-check/")
def health_check():
    return {"Message": "Okay"}


# POST API to insert data into Medicine table
@medicine_router.post("/medicines/", response_model=MedicineCreate)
def create_medicine(medicine: MedicineCreate, db: Session = Depends(get_db)):
    # create a new Medicine object
    new_medicine = Medicine(name=medicine.name, description=medicine.description)
    db.add(new_medicine)
    db.commit()
    db.refresh(new_medicine)

    # send message to Azure Storage Queue
    medicine_info = f'{{"id": "{new_medicine.id}", "Name": "{medicine.name}", "Description": "{medicine.description}"}}'

    queue_client.send_message(content=medicine_info)

    return new_medicine


# GET request with a string query parameter to find medicines
# covert content to vector -> find in ElasticSearch -> mapping ids with MySQL
@medicine_router.get("/medicines/")
def find_medicines(content: str, db: Session = Depends(get_db)):
    # embed search content to vector
    content_embedded = (
        openai_client.embeddings.create(
            model=EMBEDDING_MODEL, input=content, dimensions=NUMBER_OF_DIMENSIONS
        )
        .data[0]
        .embedding
    )

    # ElasticSearch query body in vector form
    vector_query_body = {
        "query": {
            "script_score": {
                "query": {"match_all": {}},
                "script": {
                    "source": "cosineSimilarity(params.query_vector, 'medicine_vector') + 1.0",
                    "params": {"query_vector": content_embedded},
                },
            }
        },
        "size": 3,  # get the top 3 results
        "sort": [{"_score": {"order": "desc"}}],  # sort by the highest score first
    }
    vector_query_response = es_client.search(
        index=ELASTICSEARCH_INDEX, body=vector_query_body
    )

    # extract the top 3 ids result
    medicine_ids = [
        hit["_source"]["medicine_id"] for hit in vector_query_response["hits"]["hits"]
    ]

    # query from MySQL to get the medicines
    # fetch details of the top 3 medicines from MySQL
    medicines = db.query(Medicine).filter(Medicine.id.in_(medicine_ids)).all()
    # Format the results
    results = [
        {"id": med.id, "name": med.name, "description": med.description}
        for med in medicines
    ]

    return results


app.include_router(medicine_router)
