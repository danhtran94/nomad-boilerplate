data_dir = "/var/nomad"

bind_addr = "0.0.0.0" # the default

datacenter = "sgp"

advertise {
  # Defaults to the first private IP address.
  http = "${ETH1}"
  rpc  = "${ETH1}"
  serf = "${ETH1}" # non-default ports may be specified
}

client {
  enabled       = true
  network_speed = 1000
  options = {
    "driver.raw_exec.enable" = "1"
  }
}

consul {
  address = "consul.abusy.life:8500"
  token = "7kDNG2+GDTuvfzP3tFpH2g=="
}
