# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

##
# Docker env array formatter
def format_env env
  env.map{|e| "\"#{e}\"" }.join(' -e ')
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 2
  end

  ##
  # A boot2docker base box that supports shared folders
  # and auto-corrects port collections of docker hosts (perfect)
  config.vm.box_url = "https://vagrantcloud.com/dduportal/boot2docker/version/4/provider/virtualbox.box"
  config.vm.box = "dduportal/boot2docker"

  pg_env = format_env([ 'POSTGRESQL_USER=hyperdock',
                        'POSTGRESQL_PASS=hyperdock',
                        'POSTGRESQL_DB=hyperdock' ])

  redis_args = [
    "-d",
    "--name redis",
    "-t dockerfile/redis"
  ].join(' ')

  pg_args = [
    "-d",
    "-e #{pg_env}",
    "--name pg",
    "-t orchardup/postgresql"
  ].join(' ')

  rails_args = [
    "-d",
    "-p 3000:3000",
    "--link redis:redis",
    "--link pg:pg",
    "-v /vagrant:/apps/rails",
    "-e #{pg_env}",
    "-t hyperdock"
  ].join(' ')

  config.vm.provision 'shell', inline: <<-EOF
      docker build -t hyperdock /vagrant

      docker pull dockerfile/redis
      docker run #{redis_args}

      docker pull orchardup/postgresql
      docker run #{pg_args}

      docker run #{rails_args}
  EOF

  config.vm.network "forwarded_port", guest: 3000, host: 3000
end
