# setting ElasticSearch without security

sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
sudo apt update
sudo apt install elasticsearch -y
sudo echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml
sudo echo "xpack.ml.enabled: true" >> /etc/elasticsearch/elasticsearch.yml
sudo sed -i 's/xpack.security.enabled: true/xpack.security.enabled: false/' /etc/elasticsearch/elasticsearch.yml
sudo sed -i 's/xpack.security.enrollment.enabled: true/xpack.security.enrollment.enabled: false/' /etc/elasticsearch/elasticsearch.yml
sudo sed -i '/xpack.security.http.ssl:/,/keystore.path:/s/enabled: true/enabled: false/' /etc/elasticsearch/elasticsearch.yml
sudo sed -i '/xpack.security.transport.ssl:/,/keystore.path:/s/enabled: false/enabled: true/' /etc/elasticsearch/elasticsearch.yml
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch
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