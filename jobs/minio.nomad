job "build-storage-infra" {
    datacenters = ["sgp"]

    type = "service"

    group "storage" {
        count = 1

        task "minio" {
            driver = "docker"

            config {
                image = "minio/minio"
                hostname = "minio"
                volumes = [
                    "minio:/data"
                ]
                volume_driver = "rexray/dobs"
                port_map {
                    admin = 9000
                }
                args = [
                    "server",
                    "/data"
                ]
                network_mode = "weave"
            }

            resources {
                cpu    = 500
                memory = 512
                network {
                    mbits = 1000
                    port "admin" {
                        static = 9000
                    }
                }
            }

            service {
                name = "minio"
                port = "admin"
                address_mode = "host"
                check {
                    address_mode = "driver"
                    address_mode = "host"
                    name     = "http-check"
                    type     = "http"
                    port = "admin"
                    path = "/minio/health/live"
                    interval = "10s"
                    timeout  = "2s"
                }
            }
        }
    }
}
