sudo mkdir -p /etc/docker /etc/systemd/system/docker.service.d /certs

sudo mv /tmp/ca.pem   /certs/ca.pem
sudo mv /tmp/server-key.pem  /certs/server-key.pem
sudo mv /tmp/server-cert.pem /certs/server-cert.pem

sudo mv /tmp/daemon.json /etc/docker/daemon.json
sudo mv /tmp/override.conf /etc/systemd/system/docker.service.d/override.conf

sudo systemctl daemon-reload
sudo service docker restart