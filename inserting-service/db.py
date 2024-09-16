import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from models import Base


DATABASE_URL = f"mysql+mysqldb://{os.getenv('MYSQL_DB_USER')}:{os.getenv('MYSQL_DB_PASSWORD')}@{os.getenv('MYSQL_DB_HOST')}/{os.getenv('MYSQL_DB_NAME')}"
mysql_ssl_args = {"ssl": True}


# SQLAlchemy setup
def db_connect():
    # mysql_engine = create_engine(DATABASE_URL, connect_args=mysql_ssl_args)
    # SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=mysql_engine)
    mysql_engine = create_engine(DATABASE_URL, connect_args=mysql_ssl_args)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=mysql_engine)

    # create the database tables (only if they don't exist)
    Base.metadata.create_all(bind=mysql_engine)

    return SessionLocal
