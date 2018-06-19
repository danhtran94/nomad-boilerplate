job "load-balancer" {
    datacenters = ["sgp"]

    type = "system"

    group "core" {
        count = 1

        task "traefik" {
            driver = "docker"

            config {
                image = "traefik:v1.6.4"
                hostname = "traefik"
                port_map {
                    // internal container port
                    proxy = 80
                    // default ping, health, api port
                    traefik = 8080
                }
                args = [
                    "--debug",
                    "--ping",
                    "--api",
                    "--accesslogsfile=/dev/stdout",
                    "--consulcatalog",
                    "--consulcatalog.endpoint=188.166.187.33:8500",
                ]
                network_mode = "weave"
            }

            resources {
                cpu    = 500
                memory = 256
                network {
                    mbits = 500

                    port "proxy" {
                        // host port
                        static = 80
                    }
                    port "traefik" {
                        static = 5555
                    }
                    // port "health" {
                    //     static = 8080
                    // }
                }
            }

            service {
                tags = ["lb"]
                name = "traefik"
                port = "proxy"
                address_mode = "host"
                check {
                    address_mode = "driver"
                    name     = "http-check"
                    type     = "http"
                    port = 8080
                    path = "/ping"
                    interval = "10s"
                    timeout  = "2s"
                }
            }

            service {
                name = "traefik-ui"
                tags = [
                    "traefik.tags=service",
                    "traefik.frontend.rule=Host:traefik.abusy.life;HeadersRegexp: X-Token, SUPER113",
                ]
                port = 8080
                address_mode = "driver"
                check {
                    address_mode = "driver"
                    name     = "http-check"
                    type     = "http"
                    port = 8080
                    path = "/ping"
                    interval = "10s"
                    timeout  = "2s"
                }
            }

        }
    }
}
