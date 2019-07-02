
JENKINS_URL=http://ec2-18-216-29-4.us-east-2.compute.amazonaws.com:8080

JENKINS_DOMAIN=ec2-18-216-29-4.us-east-2.compute.amazonaws.com
JENKINS_USER=iotkit
JENKINS_PASSWORD=hudew7dt76g

# crumb not needed for auth strategy
# CRUMB=$(curl -s "http://$JENKINS_USER:$JENKINS_PASSWORD@$JENKINS_DOMAIN:8080/crumbIssuer/api/json" | jq '.crumb' -r)
# curl -H "Jenkins-Crumb:$CRUMB" -X POST ...

# TODO - we need to wait here until Jenkins is ready...

curl -X POST "http://$JENKINS_USER:$JENKINS_PASSWORD@$JENKINS_DOMAIN:8080/credentials/store/system/domain/_/createCredentials" \
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

curl -X POST "http://$JENKINS_USER:$JENKINS_PASSWORD@$JENKINS_DOMAIN:8080/credentials/store/system/domain/_/createCredentials" \
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

curl -s -XPOST "http://$JENKINS_DOMAIN:8080/createItem?name=iotkit' -u $JENKINS_USER:$JENKINS_PASSWORD --data-binary @pipeline.xml -H "Content-Type:text/xml"


GITHUB_ACCESS_TOKEN="8a27dea8201ae710b3b963df3e6ffe9f9593bb34"

curl -XPOST -u iotkitdemo:$GITHUB_ACCESS_TOKEN https://api.github.com/user/repos -d '{"name":"my-new-repo","description":"my new repo description"}'