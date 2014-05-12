User.create(email: "admin@hyperdock.io", password: "12345678", role: "admin", invitation_limit: 100, container_limit: 100)

am = Region.create(name: "Amsterdam")
ny = Region.create(name: "New York")
sf = Region.create(name: "San Francisco")

if Rails.env.production?
  ny.hosts.create({
    name: "ny-01.hyperdock.io",
    ip_address: "162.243.161.151",
    port: "5422"
  })
  sf.hosts.create({
    name: "sf-01.hyperdock.io",
    ip_address: "107.170.249.184",
    port: "5422"
  })
  am.hosts.create({
    name: "am-01.hyperdock.io",
    ip_address: "188.226.227.62",
    port: "5422"
  })
else
  sf.hosts.create({
    name: "test.hyperdock.io",
    ip_address: "198.199.112.194",
    port: "5542"
  })
  sf.hosts.create({
    name: "boot2docker",
    ip_address: "192.168.33.10",
    port: "4243"
  })
end

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
  docker_index: "orchardup/docker-postgresql",
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

