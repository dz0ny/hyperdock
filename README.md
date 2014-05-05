Domain name: hyperdock.io

Hosted Application Platform built on Docket and cheap low cost VPS providers

Offered Images:
 * Logstash
 * ElasticSearch
 * Kibana
 * Graphite
 * statsd
 * strider
 * postgresql
 * redis
 * mongodb
 * hosted hipchat (the open surce thing starts with k)
 * git lab
 * sinopia
 * geminabox

Supported VPS Providers:
 * We support both virtual and dedicated servers, provider does not matter anymore.

Tenant Signs Up
 - SaaSKit

Chooses Image
Optionally edits/saves Dockerfile
Selects a Datacenter and VPS Provider
Pays
We provision and send detials via email

Container Dashboard
 - Show graphs on how client docker container is performing. 

Host Dashboard
 - Show graphs on how docker host is performing. 

You can access it using the following credentials:
IP Address: 107.170.249.80
Username: root
Password: 1

Username: app
Password: 2

# Docker Test Host
Linode
domain: cry.li
user: root
password: 3

# References

* Docker Remote API Docs: http://docs.docker.io/reference/api/docker_remote_api/
* Securing Docker Remote API via SSH Tunnel http://blog.tutum.co/2013/11/23/remote-and-secure-use-of-docker-api-with-python-part-ii/
* Securing Docker Remote API via Nginx Unix Proxy & Client Certs http://java.dzone.com/articles/securing-docker%E2%80%99s-remote-api
* Important Info about Docker Logs http://jasonwilder.com/blog/2014/03/17/docker-log-management-using-fluentd/
* More info about logging https://blog.logentries.com/2014/03/the-state-of-logging-on-docker/
* Setup rails and postgres https://www.digitalocean.com/community/articles/how-to-setup-ruby-on-rails-with-postgres
* Setup unicorn and nginx https://www.digitalocean.com/community/articles/how-to-deploy-rails-apps-using-unicorn-and-nginx-on-centos-6-5
* Collecting container metrics http://blog.docker.io/2013/10/gathering-lxc-docker-containers-metrics/

# Notes

Docker daemon logs are located at /var/log/upstart/docker.log

# Deploy
```
apt-get install nginx postgresql libpq-dev supervisor redis-server

\curl -sSL https://get.rvm.io | bash -s stable

rvm install 2.1

CREATE USER tom WITH PASSWORD 'myPassword';
bundle install --without development test
rvm wrapper $(cat .ruby-version) unicorn_rails
rvm wrapper $(cat .ruby-version) sidekiq

bin/rake db:create db:migrate db:seed RAILS_ENV=production

bin/rake assets:precompile RAILS_ENV=production

sudo ln -s /home/app/hyperdock/config/nginx/hyperdock /etc/nginx/sites-available/
sudo ln -s /home/app/hyperdock/config/supervisor/hyperdock.conf /etc/supervisor/conf.d/
sudo ln -s /etc/nginx/sites-available/hyperdock /etc/nginx/sites-enabled/
```

```
sudo ufw enable
```

```
git remote add production "app@hyperdock.io:/home/app/hyperdock"
```

```
git push production master
```


## Host Setup

First prepare the host or double check the configuration with the rake task:

`bin/rake docker:setup host="198.199.112.194" password="awefawef"`

Next login as admin and add it to the region
