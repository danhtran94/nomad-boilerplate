#!/usr/bin/env bash

# Configuration
export CURRENT=`pwd`
export BOOTSTRAP=true
export ETH0=$(ifconfig eth0 | grep 'inet addr' | sed -e 's/:/ /' | awk '{print $3}')
# export ETH1=$(ifconfig eth1 | grep 'inet addr' | sed -e 's/:/ /' | awk '{print $3}')
export CONSUL_DOMAIN="consul.abusy.life"
export CONSUL="$CONSUL_DOMAIN:8500"
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

cd /usr/local/bin/
wget https://releases.hashicorp.com/consul/1.1.0/consul_1.1.0_linux_amd64.zip
unzip consul_1.1.0_linux_amd64.zip
rm consul_1.1.0_linux_amd64.zip
cd $CURRENT

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

if $BOOTSTRAP ; then
export CONSUL_BOOTSTRAP="bootstrap_expect = 2"
export NOMAD_BOOTSTRAP="bootstrap_expect = 2"
fi

# Generate Consul Server Config
envsubst << EOF > /etc/consul.d/server/config.hcl
server = true

${CONSUL_BOOTSTRAP}

datacenter = "sgp"

data_dir = "/var/consul"

encrypt = "${CONSUL_TOKEN}"

log_level = "INFO"

enable_syslog = true

retry_join = ["${CONSUL_DOMAIN}"]

bind_addr = "0.0.0.0"

advertise_addr = "${ETH0}"

client_addr = "${ETH0}"
EOF
# -- END Generate Nomad Server Config --

# Generate Systemd Service File
cat <<EOF > /lib/systemd/system/consul.service
[Unit]
Description=Consul Service
After=network.target

[Service]
Type=simple
Restart=always
RestartSec=1
User=root
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/server
EOF
# -- END Generate Systemd Service File --

# Generate Nomad Server Config
envsubst << EOF > /etc/nomad.d/server/config.hcl
data_dir = "/var/nomad"

bind_addr = "0.0.0.0" # the default

datacenter = "sgp"

advertise {
  # Defaults to the first private IP address.
  http = "${ETH0}"
  rpc  = "${ETH0}"
  serf = "${ETH0}" # non-default ports may be specified
}

server {
  enabled = true
  ${NOMAD_BOOTSTRAP} # only one server node have this option
}

consul {
  address = "${CONSUL}"
  token = "${CONSUL_TOKEN}"
}
EOF
# -- END Generate Nomad Server Config --

# Generate Systemd Service File
cat <<EOF > /lib/systemd/system/nomad.service
[Unit]
Description=Nomad Service
After=network.target

[Service]
Type=simple
Restart=always
RestartSec=1
User=root
ExecStart=/usr/local/bin/nomad agent -config=/etc/nomad.d/server
EOF
# -- END Generate Systemd Service File --

# Start Consul Service
systemctl start consul
systemctl status consul
# -- END Start Nomad Service --

# Start Nomad Service
systemctl start nomad
systemctl status nomad
# -- END Start Nomad Service --

export WEAVE_PEERS=""
if ! $BOOTSTRAP ; then
  while [ "$WEAVE_PEERS" == "" ]
  do
    sleep 1
    WEAVE_PEERS=$(curl http://${CONSUL}/v1/catalog/nodes | jq --arg host "$HOSTNAME" -r '.[] | select (.Node != $host) | .Address')
  done
fi

# Connect Docker Network Mesh
weave launch $WEAVE_PEERS
echo "DOCKER_HOST=unix:///var/run/weave/weave.sock" >> /etc/environment
eval "$(weave env)"
# -- END Connect Docker Network Mesh --
