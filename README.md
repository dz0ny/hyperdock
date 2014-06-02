hyperdock
---

Docker Host, Image, and Container Management Platform

Supported VPS Providers:
 * DigitalOcean

Image Management
 - Add images from the Docker index with predefined port bindings and default env-var configurations

Container Dashboard
 - Show graphs on how client docker container is performing. (WIP)
 - Provide docker top and inspect data
 - Show exposed ports
 - Websocket virtual console

Container Creation
 - Choose a region
 - Choose an image
 - Fill dynamic envvars if any

Host Dashboard
 - Show graphs on how docker host is performing. (WIP)
 - Allow (re)provisioning as a Docker Host
 - Allow (re)provisioning as the Region Monitor
 - Websocket virtual console

Monitor comes with Logstash, Kibana, ElasticSearch, Sensu
 - Docker hosts provisioned in the same region auto-configure against the Monitor

# Deployment

## CONFIGURE

Make sure to edit the .env file with your Cloudflare and DigitalOcean API keys

## INSTALL

See the Dockerfile (Not yet complete, really)

The dockerfile/runner only runs `rails server` right now -- it needs to be modified to use Supervisor
and run `rake websocket_rails:start_server` as well as `sidekiq`

# Similar Projects

http://shipyard-project.com/

# References

* Why I open-sourced Hyperdock http://keyvanfatehi.com/2014/06/01/hyperdock-io/
* Does a nice job of explaining Docker http://3ofcoins.net/2013/09/22/flat-docker-images/
* Docker Remote API Docs: http://docs.docker.io/reference/api/docker_remote_api/
* Securing Docker Remote API via Nginx Unix Proxy & Client Certs http://java.dzone.com/articles/securing-docker%E2%80%99s-remote-api
* Important Info about Docker Logs http://jasonwilder.com/blog/2014/03/17/docker-log-management-using-fluentd/
* More info about logging https://blog.logentries.com/2014/03/the-state-of-logging-on-docker/
* Setup rails and postgres https://www.digitalocean.com/community/articles/how-to-setup-ruby-on-rails-with-postgres
* Setup unicorn and nginx https://www.digitalocean.com/community/articles/how-to-deploy-rails-apps-using-unicorn-and-nginx-on-centos-6-5
* Collecting container metrics http://blog.docker.io/2013/10/gathering-lxc-docker-containers-metrics/

