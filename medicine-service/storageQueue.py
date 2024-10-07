import os
from azure.storage.queue import (
    QueueServiceClient,
    TextBase64EncodePolicy,
    TextBase64DecodePolicy,
)


# initialize the Azure Queue client
def queue_connect():
    connection_string = os.getenv("QUEUE_CONNECTION_STRING")
    queue_name = os.getenv("QUEUE_NAME")
    client = QueueServiceClient.from_connection_string(
        conn_str=connection_string
    ).get_queue_client(queue_name)

    client._message_encode_policy = TextBase64EncodePolicy()
    client._message_decode_policy = TextBase64DecodePolicy()

    return client
