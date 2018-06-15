#!/usr/bin/env bash

CURRENT=`pwd`
apt-get install -y unzip
cd /usr/local/bin/
wget https://github.com/weaveworks/weave/releases/download/v2.3.0/weave
cd $CURRENT

chmod +x /usr/local/bin/weave
export WEAVE_PEERS=$(nomad node status -verbose -json  | jq --arg host "$HOSTNAME" -r '.[] | select (.Name != $host) | .Address')
weave launch --no-dns --proxy --rewrite-inspect $WEAVE_PEERS
echo "DOCKER_HOST=unix:///var/run/weave/weave.sock" >> /etc/environment
eval "$(weave env)"
