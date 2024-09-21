FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN apt update && apt install -y pkg-config gcc \
    default-libmysqlclient-dev pkg-config
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 80

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]