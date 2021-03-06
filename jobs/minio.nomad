job "storage-manager" {
    datacenters = ["sgp"]

    type = "service"

    group "core" {
        count = 1

        task "minio" {
            driver = "docker"

            config {
                image = "minio/minio:latest"
                hostname = "minio"
                volume_driver = "rexray/dobs"
                volumes = [
                    "minio:/data"
                ]
                network_mode = "weave"
                args = [
                    "server",
                    "/data"
                ]
            }

            resources {
                cpu    = 500
                memory = 512
            }

            service {
                name = "minio"
                address_mode = "driver"
                tags = [
                    "traefik.tags=service",
                    "traefik.frontend.rule=Host:minio.abusy.life",
                ]
                port = 9000
                check {
                    name     = "http-check"
                    type     = "http"
                    address_mode = "driver"
                    port = 9000
                    path = "/minio/health/live"
                    interval = "10s"
                    timeout  = "2s"
                }
            }
        }
    }
}
