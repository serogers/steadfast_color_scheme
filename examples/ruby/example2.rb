module ActionCable
  module Server
    module Broadcasting
      # Broadcast a hash directly to a named <tt>broadcasting</tt>. This will later be JSON encoded.
      def broadcast(broadcasting, message, coder: ActiveSupport::JSON)
        broadcaster_for(broadcasting, coder: coder).broadcast(message)
      end

      # Returns a broadcaster for a named <tt>broadcasting</tt> that can be reused. Useful when you have an object that
      # may need multiple spots to transmit to a specific broadcasting over and over.
      def broadcaster_for(broadcasting, coder: ActiveSupport::JSON)
        Broadcaster.new(self, String(broadcasting), coder: coder)
      end

      private
        class Broadcaster
          attr_reader :server, :broadcasting, :coder

          def initialize(server, broadcasting, coder:)
            @server, @broadcasting, @coder = server, broadcasting, coder
          end

          def broadcast(message)
            server.logger.info "[ActionCable] Broadcasting to #{broadcasting}: #{message.inspect}"

            payload = { broadcasting: broadcasting, message: message, coder: coder }
            ActiveSupport::Notifications.instrument("broadcast.action_cable", payload) do
              encoded = coder ? coder.encode(message) : message
              server.pubsub.broadcast broadcasting, encoded
            end
          end
        end
    end
  end
end