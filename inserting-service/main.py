from fastapi import FastAPI, Depends, APIRouter
from db import db_connect
from request import MedicineCreate
from sqlalchemy.orm import Session
from models import Medicine
from storageQueue import queue_connect


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
medicine_router = APIRouter(prefix="/insert")


# Health check endpoint
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


app.include_router(medicine_router)
