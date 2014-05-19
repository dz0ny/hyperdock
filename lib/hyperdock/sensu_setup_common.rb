module Hyperdock
  module SensuSetupCommon
    SENSU_CONFIG_DIR = Rails.root.join('config/sensu')
    CLIENT_DIR = SENSU_CONFIG_DIR.join('client')
    INSTALL_SCRIPT = <<-EOF
      wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
      echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list
      apt-get update
      export DEBIAN_FRONTEND=noninteractive
      apt-get install -y sensu
    EOF
    SSL_KEY = CLIENT_DIR.join('ssl/key.pem')
    SSL_CERT = CLIENT_DIR.join('ssl/cert.pem')

    def use_sensu_embedded_ruby!
      remote_write '/etc/default/sensu', "EMBEDDED_RUBY=true"
    end
    
  end
end
