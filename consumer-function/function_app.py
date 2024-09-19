import azure.functions as func
import logging
import json

# from openai import OpenAI

# OpenAI variables
EMBEDDING_MODEL = "text-embedding-3-small"
NUMBER_OF_DIMENSIONS = 1408


app = func.FunctionApp()

# openai_client = OpenAI(
#     api_key=""
# )


@app.queue_trigger(
    arg_name="azqueue",
    queue_name="medicine-inserting-queue",
    connection="elasticsearchopenaisa_STORAGE",
)
def medicine_insert_trigger(azqueue: func.QueueMessage):
    # decode the message body
    message_body = azqueue.get_body().decode("utf-8")
    medicine_info = json.loads(message_body)

    logging.info(medicine_info["Name"])
    logging.info(medicine_info["Description"])
