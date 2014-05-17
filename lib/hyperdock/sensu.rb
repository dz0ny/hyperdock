module Hyperdock
  module Sensu

    ##
    # this is called once we are sure docker is installed
    # similar to the docker provisoning, we want to be able to run this
    # at any time -- on a fresh box, partially setup box, or a complete box
    # to install, continue installing, or cleanly upgrade the monitoring system
    def use_sensu!
    end

  end
end
