#!/usr/bin/env bash
scp -rp ./var/nomad/run.sh  root@sv01:/var/nomad/
scp -rp ./var/nomad/run.sh  root@sv02:/var/nomad/
scp -rp ./lib/systemd/system/nomad.service   root@sv01:/lib/systemd/system
scp -rp ./lib/systemd/system/nomad.service   root@sv02:/lib/systemd/system
scp ./lib/systemd/system/nomad.client.service   clt01:/lib/systemd/system/nomad.service
scp -rp ./etc/nomad.d/server/config-template.hcl root@sv02:/etc/nomad.d/server
scp -rp ./etc/nomad.d/server/config-template.hcl root@sv01:/etc/nomad.d/server
scp -rp ./etc/nomad.d/client/config-template.hcl clt01:/etc/nomad.d/client
ETH1=$(ifconfig eth1 | grep 'inet addr' | sed -e 's/:/ /' | awk '{print $3}') envsubst < /etc/nomad.d/server/config-template.hcl | cat > /etc/nomad.d/server/config.hcl
ETH1=$(ifconfig eth1 | grep 'inet addr' | sed -e 's/:/ /' | awk '{print $3}') envsubst < /etc/nomad.d/client/config-template.hcl | cat > /etc/nomad.d/client/config.hcl
