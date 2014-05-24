module Hyperdock
  module SSH
    ##
    # Make things work in the browser via websockets while preserving CLI usage through rake
    module Hooks
      ##
      # register a block to receive log events
      def on_output
        if block_given?
          self.class.send(:define_method, :log, -> (line) { yield({log: line})})
          self.class.send(:define_method, :err, -> (line) { yield({err: line})})
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
    end
  end
end

