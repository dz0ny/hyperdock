# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

def format_env env
  %{-e #{env.map{|e| "\"#{e}\"" }.join(' -e ')}}
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "db" do |db|
    db.vm.network "private_network", ip: "192.168.33.10"
    db.vm.provision 'docker' do |d|
      d.pull_images 'orchardup/docker-postgresql'
      env = [ 'POSTGRESQL_USER=hyperdock',
              'POSTGRESQL_PASS=hyperdock',
              'POSTGRESQL_DB=hyperdock_production' ]
      d.run 'orchardup/docker-postgresql', args: format_env(env)
    end
  end

  config.vm.define "redis" do |db|
    db.vm.network "private_network", ip: "192.168.33.11"
    db.vm.provision 'docker' do |d|
      d.pull_images 'dockerfile/redis'
      d.run 'dockerfile/redis'
    end
  end

  config.vm.define "web" do |web|
    web.vm.network "forwarded_port", guest: 80, host: 3000
    web.vm.network "private_network", ip: "192.168.33.12"
    web.vm.provision 'docker' do |d|
      env = [ 'SUPERVISOR_PROGRAM=app-unicorn',
              'REDIS_IP=192.168.33.11',
              'POSTGRESQL_IP=192.168.33.10',
              'POSTGRESQL_USER=hyperdock',
              'POSTGRESQL_PASS=hyperdock',
              'POSTGRESQL_DB=hyperdock_production' ]
      d.build_image "/vagrant/app"
      d.run "hyperdock", args: format_env(env)
    end
  end

  config.vm.define "sidekiq" do |web|
    web.vm.network "private_network", ip: "192.168.33.13"
    web.vm.provision 'docker' do |d|
      d.build_image "/vagrant/app"
      env = [ 'SUPERVISOR_PROGRAM=app-worker-1',
              'REDIS_IP=192.168.33.11' ]
      d.run 'hyperdock', args: format_env(env)
    end
  end

  config.vm.define "docker1" do |d|
    d.vm.box_url = "https://github.com/mitchellh/boot2docker-vagrant-box/releases/download/v0.8.0/boot2docker_virtualbox.box"
    d.vm.box = "mitchellh/boot2docker"
    d.vm.network "private_network", ip: "192.168.33.20"
  end
end
