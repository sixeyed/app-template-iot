#!/bin/sh

# parse parameters
awsParameters=$(jq -c '.services | map(select(.serviceId == "aws"))[0].parameters' /run/configuration)
echo "awsParameters: $awsParameters"

export AWS_ACCESS_KEY_ID=$(echo "$awsParameters" | jq -c '.accessKeyId' --raw-output)
export AWS_SECRET_ACCESS_KEY=$(echo "$awsParameters" | jq -c '.secretAccessKey' --raw-output)
export AWS_DEFAULT_REGION=$(echo "$awsParameters" | jq -c '.defaultRegion' --raw-output)
PROJECT_NAME=$(echo "$awsParameters" | jq -c '.projectName' --raw-output)

echo "Project name: $PROJECT_NAME, default region: $AWS_DEFAULT_REGION"

# KeyPair
mkdir /certs
aws ec2 create-key-pair --key-name "$PROJECT_NAME-kp" --query 'KeyMaterial' --output text > /certs/ec2-key-pair.pem
chmod 400 /certs/ec2-key-pair.pem

# Security Group
GROUP_ID=$(aws ec2 create-security-group --group-name "$PROJECT_NAME-sg" --description "Build server security group" | jq '.GroupId' -r)
aws ec2 authorize-security-group-ingress --group-id $GROUP_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $GROUP_ID --protocol tcp --port 8080 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $GROUP_ID --protocol tcp --port 2376 --cidr 0.0.0.0/0

aws ec2 run-instances --image-id ami-0f2057f28f0a44d06 --count 1 --instance-type a1.medium \
 --key-name "$PROJECT_NAME-kp" --security-group-ids $GROUP_ID \
 --tag-specifications "ResourceType=instance,Tags=[{Key=project,Value=$PROJECT_NAME}]"

# generate certs while we wait for instance - CA
openssl rand -base64 32 > /certs/ca.password
openssl genrsa -aes256 -passout file:/certs/ca.password -out /certs/ca-key.pem 4096
openssl req -subj "/C=UK/ST=LON/L=London/O=iotkit/OU=." -new -x509 -days 3650 -passin file:/certs/ca.password -key /certs/ca-key.pem -sha256 -out /certs/ca.pem

# client
openssl genrsa -out /certs/key.pem 4096
openssl req -subj '/CN=client' -new -key /certs/key.pem -out /certs/client.csr
echo extendedKeyUsage = clientAuth > /certs/extfile-client.cnf
openssl x509 -req -days 3650 -sha256 -in /certs/client.csr -CA /certs/ca.pem -CAkey /certs/ca-key.pem -CAcreateserial -out /certs/cert.pem -extfile /certs/extfile-client.cnf -passin file:/certs/ca.password

# should be ready now - needs a rety loop really
PUBLIC_DNS=$(aws ec2 describe-instances --filters "Name=tag:project,Values=$PROJECT_NAME" --query "Reservations[].Instances[].PublicDnsName" | jq '.[0]' -r)

# server cert
openssl genrsa -out /certs/server-key.pem 4096
openssl req -subj "/CN=ip-172-31-23-116" -sha256 -new -key /certs/server-key.pem -out /certs/server.csr
echo subjectAltName = "DNS:$PUBLIC_DNS,IP:127.0.0.1" >> /certs/extfile.cnf
echo extendedKeyUsage = serverAuth >> /certs/extfile.cnf
openssl x509 -req -days 3650 -sha256 -in /certs/server.csr -CA /certs/ca.pem -CAkey /certs/ca-key.pem -CAcreateserial -out /certs/server-cert.pem -extfile /certs/extfile.cnf -passin file:/certs/ca.password

ssh -oStrictHostKeyChecking=no -i /certs/ec2-key-pair.pem ubuntu@$PUBLIC_DNS 'bash -s' < setup-docker.sh
scp -oStrictHostKeyChecking=no -i /certs/ec2-key-pair.pem ./daemon.json ubuntu@$PUBLIC_DNS:/tmp
scp -oStrictHostKeyChecking=no -i /certs/ec2-key-pair.pem ./override.conf ubuntu@$PUBLIC_DNS:/tmp
scp -oStrictHostKeyChecking=no -i /certs/ec2-key-pair.pem /certs/ca.pem ubuntu@$PUBLIC_DNS:/tmp
scp -oStrictHostKeyChecking=no -i /certs/ec2-key-pair.pem /certs/server-key.pem ubuntu@$PUBLIC_DNS:/tmp
scp -oStrictHostKeyChecking=no -i /certs/ec2-key-pair.pem /certs/server-cert.pem ubuntu@$PUBLIC_DNS:/tmp
ssh -oStrictHostKeyChecking=no -i /certs/ec2-key-pair.pem ubuntu@$PUBLIC_DNS 'bash -s' < configure-docker.sh

export DOCKER_HOST="tcp://$PUBLIC_DNS:2376"
export DOCKER_TLS_VERIFY='1'
export DOCKER_CERT_PATH='/certs'

docker swarm init
docker stack deploy -c jenkins.yml jenkins
