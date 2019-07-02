#!/bin/sh

# parse parameters
parameters=$(jq -c '.services | map(select(.serviceId == "jenkins-pipeline"))[0].parameters' /run/configuration)
username=$(echo "$parameters" | jq -c '.username' --raw-output)
password=$(echo "$parameters" | jq -c '.password' --raw-output)

parameters=$(jq -c '.services | map(select(.serviceId == "github-repo"))[0].parameters' /run/configuration)
githubUsername=$(echo "$parameters" | jq -c '.username' --raw-output)
githubAccessToken=$(echo "$parameters" | jq -c '.accessToken' --raw-output)
githubRepoName=$(echo "$parameters" | jq -c '.repoName' --raw-output)

parameters=$(jq -c '.services | map(select(.serviceId == "docker-hub-repo"))[0].parameters' /run/configuration)
hubUsername=$(echo "$parameters" | jq -c '.username' --raw-output)
hubPassword=$(echo "$parameters" | jq -c '.password' --raw-output)
hubRepoName=$(echo "$parameters" | jq -c '.repoName' --raw-output)

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
find='Please wait while Jenkins'
n=0
until [ $n -ge 10 ]
do
  index=$(curl -L $url)
  if test "${index#*$find}" != "$index"
  then	
    echo '** Jenkins is ready'
    break
  else
    echo '** Jenkins is starting up; I will wait'
  fi  
  n=$((n+1))
  sleep 10
done

echo "** Creating Docker Hub credentials"
jq --arg u "$hubUsername" --arg p "$hubPassword" '.credentials.username=$u | .credentials.password=$p' dockerHubCreds.template.json > dockerHubCreds.json
curl -u $username:$password -X POST "$url/credentials/store/system/domain/_/createCredentials" --data-binary @dockerHubCreds.json -H 'Content-Type:application/json'

echo "** Creating GitHub credentials"
jq --arg u "$githubUsername" --arg p "$githubPassword" '.credentials.username=$u | .credentials.password=$p' gitHubCreds.template.json > gitHubCreds.json
curl -u $username:$password -X POST "$url/credentials/store/system/domain/_/createCredentials" --data-binary @dockerHubCreds.json -H 'Content-Type:application/json'

# TODO fix up pipeline XML
curl -u $username:$password -s -X POST "$url/createItem?name=iotkit" --data-binary @pipeline.xml -H 'Content-Type:text/xml'

# copy the empty compose file (required by merger):
mkdir -p /project
cp docker-compose.yaml /project/docker-compose.yaml