# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

##
# Docker env array formatter
def format_env env
  env.map{|e| "\"#{e}\"" }.join(' -e ')
end

def boot2docker conf
  conf.vm.box_url = "https://github.com/mitchellh/boot2docker-vagrant-box/releases/download/v0.8.0/boot2docker_virtualbox.box"
  conf.vm.box = "mitchellh/boot2docker"
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  ##
  # Provide a Data VM to house redis and postgresql containers
  # TODO: create a custom redis container that allows setting AUTH value
  config.vm.define "data" do |db|
    boot2docker db
    db.vm.synced_folder ".", "/vagrant", disabled: true
    db.vm.network "private_network", ip: "192.168.33.10"
    env = format_env([ 'POSTGRESQL_USER=hyperdock',
                       'POSTGRESQL_PASS=hyperdock',
                       'POSTGRESQL_DB=hyperdock' ])
    db.vm.provision 'shell', inline: <<-EOF
      docker pull dockerfile/redis
      docker run           -d -p 6379:6379 -t dockerfile/redis
      docker pull orchardup/postgresql
      docker run -e #{env} -d -p 5432:5432 -t orchardup/postgresql
    EOF
  end

  ## 
  # Provide a Web VM to house nginx container and unicorn workers
  # TODO add unicorn
  config.vm.define "web" do |web|
    boot2docker web
    web.vm.network :forwarded_port, guest: 4243, host: 4244
    web.vm.network "forwarded_port", guest: 80, host: 3080
    web.vm.network "forwarded_port", guest: 443, host: 3443
    web.vm.network "private_network", ip: "192.168.33.12"
    web.vm.provision 'docker' do |d|
      env = [ 'SUPERVISOR_PROGRAM=app-unicorn',
              'REDIS_IP=192.168.33.11',
              'POSTGRESQL_IP=192.168.33.10',
              'POSTGRESQL_USER=hyperdock',
              'POSTGRESQL_PASS=hyperdock',
              'POSTGRESQL_DB=hyperdock' ]
    web.vm.provision 'shell', inline: <<-EOF
      docker pull dockerfile/nginx
      docker run           -d -p 80:80 -p 443:443 -v /vagrant/config/nginx:/etc/nginx/sites-enabled -v /vagrant/log/nginx.log:/var/log/nginx -t dockerfile/nginx
    EOF
    end
  end

  config.vm.define "sidekiq" do |sq|
    boot2docker sq
    sq.vm.network "private_network", ip: "192.168.33.13"
    sq.vm.provision 'docker' do |d|
      d.build_image "/vagrant/app"
      env = [ 'SUPERVISOR_PROGRAM=app-worker-1',
              'REDIS_IP=192.168.33.11' ]
      d.run 'hyperdock', args: format_env(env)
    end
  end

  config.vm.define "docker1" do |d|
    boot2docker d
    d.vm.network "private_network", ip: "192.168.33.20"
  end
end
