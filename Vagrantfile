# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

def format_env env
  %{-e #{env.map{|e| "\"#{e}\"" }.join(' -e ')}}
end

def boot2docker conf
  conf.vm.box_url = "https://github.com/mitchellh/boot2docker-vagrant-box/releases/download/v0.8.0/boot2docker_virtualbox.box"
  conf.vm.box = "mitchellh/boot2docker"
end

def precise64 conf
  conf.vm.box_url = "http://files.vagrantup.com/precise64.box"
  conf.vm.box = "precise64"
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "db" do |db|
    boot2docker db
    db.vm.synced_folder ".", "/vagrant", disabled: true
    db.vm.network "private_network", ip: "192.168.33.10"
    db.vm.network "forwarded_port", guest: 5432, host: 5432
    env = [ 'POSTGRESQL_USER=hyperdock',
            'POSTGRESQL_PASS=hyperdock',
            'POSTGRESQL_DB=hyperdock' ]
    db.vm.provision 'shell', inline: <<-EOF
      docker pull orchardup/postgresql
      docker run #{format_env(env)} -d -p 5432:5432 -t orchardup/postgresql
    EOF
  end

  config.vm.define "redis" do |redis|
    boot2docker redis
    redis.vm.network "private_network", ip: "192.168.33.11"
    redis.vm.provision 'docker' do |d|
      d.pull_images 'dockerfile/redis'
      d.run 'dockerfile/redis'
    end
  end

  config.vm.define "web" do |web|
    boot2docker web
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
