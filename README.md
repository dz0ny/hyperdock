**Docker Host, Image, and Container Management Platform**

*IRC Channel: #hyperdock on Freenode*

---

## Supported VPS Providers:
 * DigitalOcean

## Image Management
 - Add images from the Docker index with predefined port bindings and default env-var configurations

## Container Management
 - Show graphs on how client docker container is performing. (WIP)
 - Provide docker top and inspect data
 - Show exposed ports
 - Websocket virtual console

### Simple Container Creation
 - Choose a region
 - Choose an image
 - Fill environment variables based on selected Image

## Host Dashboard
 - Show graphs on how docker host is performing. (WIP)
 - Websocket virtual console
 - Allow (re)provisioning as a Docker Host via virtual console
 - Allow (re)provisioning as the Region Monitor via virtual console

Monitor comes with Logstash, Kibana, ElasticSearch, Sensu
 - Docker hosts provisioned in the same region auto-configure against the Monitor

# Deployment

Need better instructions...

## CONFIGURE

Make sure to edit the .env file with your Cloudflare and DigitalOcean API keys

## INSTALL

See the Dockerfile Not yet complete, sorry, I think the dockerfile/runner only runs `rails server` right now -- but it needs to be modified to use supervisor, redis, and run `rake websocket_rails:start_server` as well as `sidekiq`

# Similar Projects

http://shipyard-project.com/

# Contributors

* Jeanre Swanepoel
* Keyvan Fatehi
 - Why I open-sourced Hyperdock http://keyvanfatehi.com/2014/06/01/hyperdock-io/
