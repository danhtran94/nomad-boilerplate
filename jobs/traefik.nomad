job "build-infra" {
    datacenters = ["sgp"]

    type = "service"

    group "loadbalancer" {
        count = 1

        task "traefik" {
            driver = "docker"

            config {
                image = "traefik:1.6.2"
                hostname = "traefik"
                port_map {
                    // internal container port
                    proxy = 80
                    // admin = 8080
                }
                args = [
                    "--debug",
                    "--accesslogsfile=/dev/stdout",
                    "--web",
                    "--consulcatalog",
                    "--consulcatalog.endpoint=consul.abusy.life:8500",
                ]
                network_mode = "weave"
            }

            resources {
                cpu    = 100
                memory = 128
                network {
                    mbits = 1000

                    port "proxy" {
                        // host port
                        static = 8080
                    }
                    // port "admin" {
                    //     static = 8081
                    // }
                    // port "health" {
                    //     static = 8080
                    // }
                }
            }

            service {
                name = "traefik-internal"
                port = 80
                address_mode = "driver"
                check {
                    name     = "http-check"
                    type     = "http"
                    path = "/ping"
                    port = 8080
                    address_mode = "driver"
                    interval = "10s"
                    timeout  = "2s"
                }
            }

            service {
                name = "traefik"
                port = "proxy"
                address_mode = "host"
                check {
                    address_mode = "driver"
                    // address_mode = "host"
                    name     = "http-check"
                    type     = "http"
                    // port = "admin"
                    port = 8080
                    path = "/ping"
                    interval = "10s"
                    timeout  = "2s"
                }
            }

            // service {
            //     name = "traefik-ui"
            //     port = "ui"
            //     check {
            //         name     = "traefik-ui-check"
            //         type     = "http"
            //         path = "/"
            //         port = "ui"
            //         interval = "10s"
            //         timeout  = "2s"
            //     }
            // }

        }
    }
}
