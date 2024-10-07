import azure.functions as func
import logging
import json
from openai import OpenAI
import os
from elasticsearch import Elasticsearch


# OpenAI variables
EMBEDDING_MODEL = "text-embedding-3-small"
NUMBER_OF_DIMENSIONS = 1408

# connect to ElasticSearch
es_client = Elasticsearch(
    [
        {
            "host": os.environ["ELASTICSEARCH_HOST"],
            "port": int(os.environ["ELASTICSEARCH_PORT"]),
            "scheme": "http",
        }
    ]
)
ES_INDEX = os.environ["ELASTICSEARCH_INDEX"]


app = func.FunctionApp()

openai_client = OpenAI(api_key=os.environ["OPENAI_API_KEY"])


@app.queue_trigger(
    arg_name="azqueue",
    queue_name="medicine-inserting-queue",
    connection="elasticsearchopenaisa_STORAGE",
)
def medicine_insert_trigger(azqueue: func.QueueMessage):
    # decode the message body
    message_body = azqueue.get_body().decode("utf-8")
    medicine_info = json.loads(message_body)

    # embed medicine info into vector
    # USING F-STRING CONCATENATION HERE WILL CAUSE AZURE FUNCTION DISAPPEAR!
    medicine_pre_embedded = (
        "Medicine name: "
        + medicine_info["Name"]
        + "\n\n"
        + "Medicine description: "
        + medicine_info["Description"]
    )
    medicine_embedded = (
        openai_client.embeddings.create(
            model=EMBEDDING_MODEL,
            input=medicine_pre_embedded,
            dimensions=NUMBER_OF_DIMENSIONS,
        )
        .data[0]
        .embedding
    )

    # Write vectors to ElasticSearch
    es_client.index(
        index=ES_INDEX,
        body={"medicine_id": medicine_info["id"], "medicine_vector": medicine_embedded},
    )

    # logging.info("Insert successfully!")
