# frozen_string_literal: true

module ActiveRecordPgnats
  # Writes the server and its subscriptions into schema.rb.
  #
  # Hooks #tables, as F(x) does, and for the same reason: #extensions is private
  # and is redefined by the PostgreSQL-specific dumper, so a module prepended to
  # ActiveRecord::SchemaDumper never intercepts it and the dump comes out silently
  # missing its pgnats section.
  #
  # Emitted after super: a subscription names a function, and that function is
  # created by a statement above it.
  #
  # @api private
  module SchemaDumper
    def tables(stream)
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
