User.create(email: "admin@hyperdock.io", password: "12345678", role: "admin", invitation_limit: 100, container_limit: 100)

##
# This block of images is commented out because they need
# configuration options to be broken out to the hyperdock level
# Image.create({
#   name: "Sinopia",
#   description: "NPM Caching Proxy",
#   docker_index: "keyvanfatehi/docker-sinopia",
#   port_bindings: "4873"
# })
# 
# Image.create({
#   name: "MongoDB",
#   description: "NoSQL Database",
#   docker_index: "dockerfile/mongodb",
#   port_bindings: "27017, 28017"
# })
# 
# Image.create({
#   name: "Redis",
#   description: "Key-value Store",
#   docker_index: "dockerfile/redis",
#   port_bindings: "6379"
# })

Image.create({
  name: "PostgreSQL",
  description: "SQL Database",
  docker_index: "orchardup/postgresql",
  port_bindings: "5432",
  env_defaults: {
    POSTGRESQL_USER: "my_user",
    POSTGRESQL_PASS: "my_password",
    POSTGRESQL_DB: "my_database"
  }
})

Image.create({
  name: "ZNC",
  description: "IRC Bouncer",
  docker_index: "hyperdock/znc",
  port_bindings: "36660",
  env_defaults: {
    ZNC_USER: "my_admin",
    ZNC_PASS: "my_password"
  }
})

##
# This image can't be restarted
# it exposes a problem with our PortBindings JSON
# Try it out and fix the bug
Image.create({
  name: "ZNC",
  description: "IRC Bouncer",
  docker_index: "blalor/docker-influxdb",
  port_bindings: "2003 8083 8086 8090 8099"
})
