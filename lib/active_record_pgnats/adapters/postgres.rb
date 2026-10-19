# frozen_string_literal: true

require "active_record_pgnats/adapters/postgres/connection"
require "active_record_pgnats/adapters/postgres/servers"
require "active_record_pgnats/adapters/postgres/subscriptions"
require "active_record_pgnats/publish_trigger"

module ActiveRecordPgnats
  module Adapters
    # The Postgres adapter. pgnats is a Postgres extension, so there is no other
    # engine to support, but the interface is F(x)'s so an alternative could be
    # substituted the same way.
    class Postgres
      def initialize(connectable = ActiveRecord::Base)
        @connectable = connectable
      end

      def pgnats_enabled?
        connection.pgnats_enabled?
      end

      # @return [Array<ActiveRecordPgnats::Server>]
      def servers
        return [] unless pgnats_enabled?

        Servers.all(connection)
      end

      # @return [Array<ActiveRecordPgnats::Subscription>]
      def subscriptions
        return [] unless pgnats_enabled?

        Subscriptions.all(connection)
      end

      def create_server(name, options)
        execute(<<~SQL)
          CREATE SERVER #{quote_name(name)} FOREIGN DATA WRAPPER pgnats_fdw
            OPTIONS (#{options.map { |key, value| "#{key} #{quote(value)}" }.join(", ")});
        SQL

        reload_conf
      end

      # ALTER SERVER takes SET for an option already present and ADD for one that
      # is not, and rejects the wrong verb, so the current options are read back
      # and diffed. Anything absent from `options` is dropped -- the hash is the
      # desired state, not a patch.
      def update_server(name, options)
        current = server_options(name)

        changes = options.map { |key, value| "#{current.key?(key) ? "SET" : "ADD"} #{key} #{quote(value)}" }
        changes += (current.keys - options.keys).map { |key| "DROP #{key}" }

        return if changes.empty?

        execute("ALTER SERVER #{quote_name(name)} OPTIONS (#{changes.join(", ")});")
        reload_conf
      end

      def drop_server(name)
        execute("DROP SERVER #{quote_name(name)};")
        reload_conf
      end

      def create_subscription(subject, function)
        execute("SELECT nats_subscribe(#{quote(subject)}, #{quote(function)}::regproc);")
      end

      def drop_subscription(subject, function)
        execute("SELECT nats_unsubscribe(#{quote(subject)}, #{quote(function)}::regproc);")
      end

      def create_publish_trigger(table, subject)
        execute(PublishTrigger.sql(table: table, subject: subject))
      end

      def drop_publish_trigger(table)
        execute(PublishTrigger.drop_sql(table: table))
      end

      # Tells the running background worker to pick the server's options back up;
      # without it the new configuration only takes effect on the next connect.
      def reload_conf
        execute("SELECT pgnats_reload_conf();")
      end

      private

      attr_reader :connectable

      def connection
        Connection.new(connectable.connection)
      end

      def execute(sql)
        connection.execute(sql)
      end

      def server_options(name)
        servers.find { |server| server.name == name.to_s }&.options || {}
      end

      def quote(value)
        connection.quote(value.to_s)
      end

      def quote_name(name)
        connection.quote_table_name(name)
      end
    end
  end
end
