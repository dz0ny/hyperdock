# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create(email: "admin@hyperdock.io", password: "12345678", role: "admin", invitation_limit: 100, container_limit: 100)

ny = Region.create(name: "New York")
ny.hosts.create({
  name: "ny-01.hyperdock.io",
  ip_address: "162.243.161.151",
  port: "5422"
})

sf = Region.create(name: "San Francisco")
sf.hosts.create({
  name: "sf-01.hyperdock.io",
  ip_address: "107.170.249.184",
  port: "5422"
})

am = Region.create(name: "Amsterdam")
am.hosts.create({
  name: "am-01.hyperdock.io",
  ip_address: "188.226.227.62",
  port: "5422"
})

Image.create({
  name: "Sinopia",
  description: "NPM Caching Proxy",
  docker_index: "keyvanfatehi/docker-sinopia",
  port_bindings: "4873"
})

Image.create({
  name: "MongoDB",
  description: "NoSQL Database",
  docker_index: "dockerfile/mongodb",
  port_bindings: "27017, 28017"
})

Image.create({
  name: "Redis",
  description: "In-Memory Key-Value Store",
  docker_index: "dockerfile/redis",
  port_bindings: "6379"
})

Image.create({
  name: "PostgreSQL",
  description: "In-Memory Key-Value Store",
  docker_index: "dockerfile/redis",
  port_bindings: "6379"
})

Image.create({
  name: "ZNC",
  description: "IRC Bouncer",
  docker_index: "hyperdock/znc",
  port_bindings: "36660"
})

