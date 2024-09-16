from fastapi import FastAPI
from db import db_connect

# connect to MySQL db
db_connect()


app = FastAPI()


# Health check endpoint
@app.get("/health-check/")
def health_check():
    return {"Message": "Okay"}
