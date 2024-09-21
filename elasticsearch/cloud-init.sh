#!/bin/sh
apt update
apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-8.x.list
apt update
apt install elasticsearch -y
echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml
echo "xpack.ml.enabled: true" >> /etc/elasticsearch/elasticsearch.yml
sed -i 's/xpack.security.enabled: true/xpack.security.enabled: false/' /etc/elasticsearch/elasticsearch.yml
sed -i 's/xpack.security.enrollment.enabled: true/xpack.security.enrollment.enabled: false/' /etc/elasticsearch/elasticsearch.yml
sed -i '/xpack.security.http.ssl:/,/keystore.path:/s/enabled: true/enabled: false/' /etc/elasticsearch/elasticsearch.yml
sed -i '/xpack.security.transport.ssl:/,/keystore.path:/s/enabled: false/enabled: true/' /etc/elasticsearch/elasticsearch.yml
systemctl start elasticsearch
systemctl enable elasticsearch
# index medicine_vectors initiation
curl --location --request PUT 'http://localhost:9200/medicine_vectors' \
--header 'Content-Type: application/json' \
--data '{
  "mappings": {
    "properties": {
      "medicine_id": {
        "type": "integer"
      },
      "medicine_vector": {
        "type": "dense_vector",
        "dims": 1408
      }
    }
  }
}'