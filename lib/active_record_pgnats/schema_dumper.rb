# frozen_string_literal: true

module ActiveRecordPgnats
  # Writes the server and its subscriptions into schema.rb.
  #
  # @api private
  module SchemaDumper
    # Appends the pgnats section to the schema.
    #
    # @parameter stream [IO] the schema being written.
    # @returns [void] #tables is the hook, as it is in F(x) and for the same reason: #extensions is private and is redefined by the PostgreSQL-specific dumper, so a prepended module never intercepts it and the dump comes out silently missing its pgnats section.
    def tables(stream)
      # After super, because a subscription names a function that a statement above it creates.
      super

      nats_servers(stream)
      nats_subscriptions(stream)
    end

    private

      def nats_servers(stream)
        ActiveRecordPgnats.database.servers.each do |server|
          stream.puts
          stream.puts(server.to_schema)
        end
      end

      def nats_subscriptions(stream)
        ActiveRecordPgnats.database.subscriptions.each do |subscription|
          stream.puts
          stream.puts(subscription.to_schema)
        end
      end
  end
end
