#!/bin/sh

# parse parameters
parameters=$(jq -c '.services | map(select(.serviceId == "jenkins-pipeline"))[0].parameters' /run/configuration)
username=$(echo "$parameters" | jq -c '.username' --raw-output)
password=$(echo "$parameters" | jq -c '.password' --raw-output)

parameters=$(jq -c '.services | map(select(.serviceId == "github-repo"))[0].parameters' /run/configuration)
githubUsername=$(echo "$parameters" | jq -c '.username' --raw-output)
githubAccessToken=$(echo "$parameters" | jq -c '.accessToken' --raw-output)
githubRepoName=$(echo "$parameters" | jq -c '.repoName' --raw-output)

# can't pass output in JSON, so need to query AWS again
# output=$(jq -c '.outputs | map(select(.serviceId == "arm-build-server"))[0].output' /run/configuration)
# url=$(echo "$output" | jq -c '.url' --raw-output)

parameters=$(jq -c '.services | map(select(.serviceId == "arm-build-server"))[0].parameters' /run/configuration)
export AWS_ACCESS_KEY_ID=$(echo "$parameters" | jq -c '.accessKeyId' --raw-output)
export AWS_SECRET_ACCESS_KEY=$(echo "$parameters" | jq -c '.secretAccessKey' --raw-output)
export AWS_DEFAULT_REGION=$(echo "$parameters" | jq -c '.defaultRegion' --raw-output)
PROJECT_NAME=$(echo "$parameters" | jq -c '.projectName' --raw-output)

PUBLIC_DNS=$(aws ec2 describe-instances --filters "Name=tag:project,Values=$PROJECT_NAME" --query "Reservations[].Instances[].PublicDnsName" | jq '.[0]' -r)
url="http://$PUBLIC_DNS:8080"

# spin until Jenkins is ready
n=0
until [ $n -ge 5 ]
do
  PUBLIC_DNS=$(aws ec2 describe-instances --filters "Name=tag:project,Values=$PROJECT_NAME" --query "Reservations[].Instances[].PublicDnsName" | jq '.[0]' -r)
  if [ -z "$PUBLIC_DNS" ]
  then 
    echo "** EC2 instance created, waiting on public DNS"
  else
    echo "** EC2 instance created, public DNS: $PUBLIC_DNS"
    break
  fi  
  n=$[$n+1]
  sleep 5
done

echo "** Creating Docker Hub credentials"
curl -u $username:$password -X POST "$url/credentials/store/system/domain/_/createCredentials" \
--data-urlencode 'json={
  "": "0",
  "credentials": {
    "scope": "GLOBAL",
    "id": "docker-hub",
    "username": "iotkitci",
    "password": "G/xUe@@p6o8f",
    "description": "docker-hub",
    "$class": "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"
  }
}'

echo "** Creating GitHub credentials"
curl -u $username:$password -X POST "$url/credentials/store/system/domain/_/createCredentials" \
--data-urlencode 'json={
  "": "0",
  "credentials": {
    "scope": "GLOBAL",
    "id": "github",
    "username": "iotkitdemo",
    "password": "N*uuM:b\"}y9.",
    "description": "github",
    "$class": "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"
  }
}'

# TODO fix up pipeline XML
curl -u $username:$password -s -X POST "$url/createItem?name=iotkit' --data-binary @pipeline.xml -H "Content-Type:text/xml"

# copy the empty compose file (required by merger):
mkdir -p /project
cp docker-compose.yaml /project/docker-compose.yaml