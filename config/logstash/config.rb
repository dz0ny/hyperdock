{
  # The network section covers network configuration :)
  "network": {
    # A list of downstream servers listening for our messages.
    # logstash-forwarder will pick one at random and only switch if
    # the selected one appears to be dead or unresponsive
    "servers": [ "localhost:5043" ],

    # The path to your client ssl certificate (optional)
    "ssl certificate": "/opt/logstash-forwarder/ssl/cert.pem",
    # The path to your client ssl key (optional)
    "ssl key": "/opt/logstash-forwarder/ssl/key.pem",

    # The path to your trusted ssl CA file. This is used
    # to authenticate your downstream server.
    "ssl ca": "/opt/logstash-forwarder/ssl/cert.pem",

    # Network timeout in seconds. This is most important for
    # logstash-forwarder determining whether to stop waiting for an
    # acknowledgement from the downstream server. If an timeout is reached,
    # logstash-forwarder will assume the connection or server is bad and
    # will connect to a server chosen at random from the servers list.
    "timeout": 15
  },

  # The list of files configurations
  "files": [
    # An array of hashes. Each hash tells what paths to watch and
    # what fields to annotate on events from those paths.
    {
      "paths": [ 
        # single paths are fine
        "/var/log/messages",
        # globs are fine too, they will be periodically evaluated
        # to see if any new files match the wildcard.
        "/var/log/*.log"
      ],

      # A dictionary of fields to annotate on each event.
      "fields": { "type": "syslog" }
    }, {
      # A path of "-" means stdin.
      "paths": [ "-" ],
      "fields": { "type": "stdin" }
    }, {
      "paths": [
        "/var/log/apache/httpd-*.log"
      ],
      "fields": { "type": "apache" }
    }
  ]
}
