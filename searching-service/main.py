from fastapi import FastAPI, Depends, APIRouter
from openai import OpenAI
import os
from sqlalchemy.orm import Session
from db import db_connect, es_client, ELASTICSEARCH_INDEX
from models import Medicine

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


app = FastAPI()
medicine_router = APIRouter(prefix="/search")


# health check endpoint
@medicine_router.get("/health-check/")
def health_check():
    return {"Message": "Okay"}


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
