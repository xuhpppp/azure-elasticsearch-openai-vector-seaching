import os
from azure.storage.queue import QueueServiceClient


# initialize the Azure Queue client
def queue_connect():
    connection_string = os.getenv("QUEUE_CONNECTION_STRING")
    queue_name = os.getenv("QUEUE_NAME")
    return QueueServiceClient.from_connection_string(
        conn_str=connection_string
    ).get_queue_client(queue_name)
