data_dir = "/var/nomad"

bind_addr = "0.0.0.0" # the default

datacenter = "sgp"

advertise {
  # Defaults to the first private IP address.
  http = "${ETH1}"
  rpc  = "${ETH1}"
  serf = "${ETH1}" # non-default ports may be specified
}

server {
  enabled = true
  bootstrap_expect = 2 # only one server node have this option
}

consul {
  address = "consul.abusy.life:8500"
  token = "7kDNG2+GDTuvfzP3tFpH2g=="
}
