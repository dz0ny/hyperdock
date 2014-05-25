module Hyperdock
  module SSH
    ##
    # Make things work in the browser via websockets while preserving CLI usage through rake
    module Hooks
      ##
      # register a block to receive log events
      def on_output
        if block_given?
          self.class.send(:define_method, :log, -> (line) {
            yield(line.strip, nil) if line 
          })
          self.class.send(:define_method, :err, -> (line) {
            yield(nil, line.strip) if line 
          })
        end
        self
      end

      ##
      # register a block to handle exit
      def on_exit
        if block_given?
          self.class.send(:define_method, :exit, -> (code) { yield(code) })
        end
        self
      end

      def after_configured_passwordless_login
        if block_given?
          self.class.send(:define_method, :_after_configured_passwordless_login, -> { yield() })
        end
        self
      end

      def before_connect
        if block_given?
          self.class.send(:define_method, :_before_connect, -> { yield() })
        end
        self
      end

      ##
      # hook into what would otherwise update variables in the .env file
      def on_update_env
        if block_given?
          self.class.send(:define_method, :update_local_env, -> (hash) {
            hash.each {|k,v| yield(k.downcase.to_sym, v) }
          })
        end
        self
      end

      def set_monitor
        if block_given?
          self.class.send(:define_method, :monitor, -> { yield() })
        end
        self
      end
    end
  end
end

