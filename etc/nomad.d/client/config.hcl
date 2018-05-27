data_dir = "/var/nomad"

bind_addr = "0.0.0.0" # the default

datacenter = "spg1"

advertise {
  # Defaults to the first private IP address.
  http = "== ip:port that expose for other server nodes =="
  rpc  = "== ip:port that expose for other server nodes =="
  serf = "== ip:port that expose for other server nodes ==" # non-default ports may be specified
}

client {
  enabled       = true
  network_speed = 1000
}

consul {
  address = "127.0.0.1:8500"
}
