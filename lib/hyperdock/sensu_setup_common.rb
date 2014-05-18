module Hyperdock
  module SensuSetupCommon
    SENSU_CONFIG_DIR = Rails.root.join('config/sensu')
    INSTALL_SCRIPT = <<-EOF
      wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
      echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list
      apt-get update
      export DEBIAN_FRONTEND=noninteractive
      apt-get install -y sensu
    EOF
  end
end
