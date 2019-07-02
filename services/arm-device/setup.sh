#!/bin/sh

# parse parameters
parameters=$(jq -c '.services | map(select(.serviceId == "arm-device"))[0].parameters' /run/configuration)
ipAddress=$(echo "$parameters" | jq -c '.ipAddress' --raw-output)
username=$(echo "$parameters" | jq -c '.username' --raw-output)
password=$(echo "$parameters" | jq -c '.password' --raw-output)

mkdir /certs

echo "** Generating CA cert"
openssl rand -base64 32 > /certs/ca.password
openssl genrsa -aes256 -passout file:/certs/ca.password -out /certs/ca-key.pem 4096
openssl req -subj "/C=UK/ST=LON/L=London/O=iotkit/OU=." -new -x509 -days 3650 -passin file:/certs/ca.password -key /certs/ca-key.pem -sha256 -out /certs/ca.pem

echo "** Generating client cert"
openssl genrsa -out /certs/key.pem 4096
openssl req -subj '/CN=client' -new -key /certs/key.pem -out /certs/client.csr
echo extendedKeyUsage = clientAuth > /certs/extfile-client.cnf
openssl x509 -req -days 3650 -sha256 -in /certs/client.csr -CA /certs/ca.pem -CAkey /certs/ca-key.pem -CAcreateserial -out /certs/cert.pem -extfile /certs/extfile-client.cnf -passin file:/certs/ca.password

echo "** Generating server cert"
openssl genrsa -out /certs/server-key.pem 4096
openssl req -subj "/CN=device" -sha256 -new -key /certs/server-key.pem -out /certs/server.csr
echo subjectAltName = "IP:$ipAddress,IP:127.0.0.1" >> /certs/extfile.cnf
echo extendedKeyUsage = serverAuth >> /certs/extfile.cnf
openssl x509 -req -days 3650 -sha256 -in /certs/server.csr -CA /certs/ca.pem -CAkey /certs/ca-key.pem -CAcreateserial -out /certs/server-cert.pem -extfile /certs/extfile.cnf -passin file:/certs/ca.password

echo "** Installing Docker"
sshpass -p $password ssh -oStrictHostKeyChecking=no $username@$ipAddress 'bash -s' < setup-docker.sh

echo "** Configuring Docker for remote access"
sshpass -p $password scp -oStrictHostKeyChecking=no ./daemon.json $username@$ipAddress:/etc/docker
sshpass -p $password scp -oStrictHostKeyChecking=no ./override.conf $username@$ipAddress:/etc/systemd/system/docker.service.d
sshpass -p $password scp -oStrictHostKeyChecking=no /certs/ca.pem $username@$ipAddress:/certs
sshpass -p $password scp -oStrictHostKeyChecking=no /certs/server-key.pem $username@$ipAddress:/certs
sshpass -p $password scp -oStrictHostKeyChecking=no /certs/server-cert.pem $username@$ipAddress:/certs
sshpass -p $password ssh -oStrictHostKeyChecking=no $username@$ipAddress 'bash -s' < configure-docker.sh

export DOCKER_HOST="tcp://$ipAddress:2376"
export DOCKER_TLS_VERIFY='1'
export DOCKER_CERT_PATH='/certs'
docker swarm init

mkdir -p /project/certs
cp /certs/ca.pem /project/certs
cp /certs/cert.pem /project/certs
cp /certs/key.pem /project/certs
echo $ipAddress > /project/device-ip

/interpolator -source /assets -destination /assets
cp /assets/docker-compose.yaml /project/docker-compose.yaml