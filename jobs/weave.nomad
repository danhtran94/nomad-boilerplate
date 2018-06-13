job "setup-infra" {
    datacenters = ["sgp"]

    type = "system"

    constraint {
        attribute = "${attr.kernel.name}"
        value     = "linux"
    }

    group "tools" {

        task "setup-weave" {
            driver = "raw_exec"

            config {
                command = "/bin/bash"
                args = [
                    "-c", "cp local/weave /usr/local/bin && chmod +x /usr/local/bin/weave && weave launch --no-dns --proxy --rewrite-inspect && echo \"unix:///var/run/weave/weave.sock\" >> /etc/environment && eval \"$(weave env)\""
                ]
            }

            artifact {
                source = "https://github.com/weaveworks/weave/releases/download/v2.3.0/weave"
            }
        }
    }
}
