#!/usr/bin/env bash

# Configuration
export CURRENT=`pwd`
export ETH0=$(ifconfig eth0 | grep 'inet addr' | sed -e 's/:/ /' | awk '{print $3}')
# export ETH1=$(ifconfig eth1 | grep 'inet addr' | sed -e 's/:/ /' | awk '{print $3}')
export CONSUL="consul.abusy.life:8500"
export CONSUL_TOKEN="7kDNG2+GDTuvfzP3tFpH2g=="
# -- END Configuration --

# Install Dependencies
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
sudo apt-add-repository 'deb http://us.archive.ubuntu.com/ubuntu vivid main universe'

sudo apt-get update
apt-cache policy docker-engine
sudo apt-get install -y docker-engine
apt-get install -y unzip
sudo apt-get install -y jq

# cd /usr/local/bin/
# wget https://releases.hashicorp.com/consul/1.1.0/consul_1.1.0_linux_amd64.zip
# unzip consul_1.1.0_linux_amd64.zip
# rm consul_1.1.0_linux_amd64.zip
# cd $CURRENT

cd /usr/local/bin/
wget https://releases.hashicorp.com/nomad/0.8.3/nomad_0.8.3_linux_amd64.zip
unzip nomad_0.8.3_linux_amd64.zip
rm nomad_0.8.3_linux_amd64.zip
cd $CURRENT

cd /usr/local/bin/
wget https://github.com/weaveworks/weave/releases/download/v2.3.0/weave
cd $CURRENT
chmod +x /usr/local/bin/weave
# -- END Install Dependencies --

# Create Directories
mkdir -p /etc/{nomad.d,consul.d}/{server,client}
mkdir -p /var/{consul,nomad}
# -- END Create Directories --

# Generate Nomad Client Config
envsubst << EOF > /etc/nomad.d/client/config.hcl
data_dir = "/var/nomad"

bind_addr = "0.0.0.0" # the default

datacenter = "sgp"

advertise {
  # Defaults to the first private IP address.
  http = "${ETH0}"
  rpc  = "${ETH0}"
  serf = "${ETH0}" # non-default ports may be specified
}

client {
  enabled       = true
  network_speed = 1000
  options = {
    "driver.raw_exec.enable" = "1"
  }
}

consul {
  address = "${CONSUL}"
  token = "${CONSUL_TOKEN}"
}
EOF
# -- END Generate Nomad Client Config --

# Generate Systemd Service File
cat << EOF > /lib/systemd/system/nomad.service
[Unit]
Description=Nomad Service
After=network.target

[Service]
Type=simple
Restart=always
RestartSec=1
User=root
ExecStart=/usr/local/bin/nomad agent -config=/etc/nomad.d/client
EOF
# -- END Generate Systemd Service File --

# Start Nomad Service
systemctl start nomad
systemctl status nomad
# -- END Start Nomad Service --

# Connect Docker Network Mesh
sleep 10
export WEAVE_PEERS=$(nomad node status -verbose -json  | jq --arg host "$HOSTNAME" -r '.[] | select (.Name != $host) | .Address')
weave launch --no-dns --proxy --rewrite-inspect $WEAVE_PEERS
echo "DOCKER_HOST=unix:///var/run/weave/weave.sock" >> /etc/environment
eval "$(weave env)"
# -- END Connect Docker Network Mesh --
