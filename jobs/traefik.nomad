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
                    public = 80
                    ui = 8080
                    health = 8082
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
                    port "ui" {
                        static = 8080
                    }
                    // port "public" {
                    //     static = 8000
                    // }
                    // port "health" {
                    //     static = 8082
                    // }
                }
            }

            service {
                name = "traefik-internal"
                // port = "http"
                port = 80
                address_mode = "driver"
                check {
                    name     = "traefik-check"
                    type     = "http"
                    path = "/"
                    port = 8080
                    address_mode = "driver"
                    interval = "10s"
                    timeout  = "2s"
                }
            }

            // service {
            //     name = "traefik-public"
            //     port = "public"
            //     check {
            //         name     = "traefik-check"
            //         type     = "http"
            //         path = "/"
            //         port = "ui"
            //         interval = "10s"
            //         timeout  = "2s"
            //     }
            // }

            service {
                name = "traefik-ui"
                port = "ui"
                check {
                    name     = "traefik-ui-check"
                    type     = "http"
                    path = "/"
                    port = "ui"
                    interval = "10s"
                    timeout  = "2s"
                }
            }

        }
    }
}
