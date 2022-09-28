project = "workshops"

config {
  internal = {
    "key" = configdynamic("kubernetes", {
      name   = "stripe-key"
      key    = "key"
      secret = true
    }),
    "pubkey" = configdynamic("kubernetes", {
      name = "pub-key"
      key  = "pub"

      secret = true
    })
  }
  env = {
    "PUBLISHABLE_KEY" = "${config.internal.pubkey}",
    "SECRET_KEY"      = "${config.internal.key}",
    "DOMAIN"          = "https://waypoint.5a3b223a-d26d-4cc8-bf7a-b6e84b0e9b09.lb.civo.com",
    "STATIC_DIR"      = "./client/"
    "PORT"            = "3000" 
  }
}


variable "user" {
  default = "saiyam911"
  type    = string
}
variable "password" {
  default = dynamic("kubernetes", {
    name   = "demo"
    key    = "password"
    secret = true
  })
  type      = string
  sensitive = true
}

app "demo" {

  build {
    use "pack" {}

    registry {
      use "docker" {
        image    = "saiyam911/workshops"
        tag      = "${substr(gitrefhash(), 0, 7)}-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
        local    = false
        username = var.user
        password = var.password
      }
    }
  }

  deploy {
    use "kubernetes" {
      service_port = 3000
    }
  }

  release {
    use "kubernetes" {
      ingress "http" {
        host      = "waypoint.5a3b223a-d26d-4cc8-bf7a-b6e84b0e9b09.lb.civo.com"
        path_type = "Prefix"
        path      = "/"
        tls {
          hosts       = ["waypoint.5a3b223a-d26d-4cc8-bf7a-b6e84b0e9b09.lb.civo.com"]
          secret_name = "workshop"
        }
      }
    }
  }
}
