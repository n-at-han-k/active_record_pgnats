# frozen_string_literal: true

module ActiveRecordPgnats
  # The migration DSL for pgnats.
  module Statements
    # The options pgnats reads off its foreign server.
    SERVER_OPTIONS = %i[
      host port capacity tls_ca_path tls_cert_path tls_key_path notify_subject patroni_url
    ].freeze

    # Creates pgnats' foreign server, its whole configuration.
    #
    # @example
    #   create_nats_server :nats, host: "127.0.0.1", port: 4222
    #
    # @parameter name [String | Symbol] the server's name, the migration's to choose.
    # @parameter revert_to [Hash] unused here; the command recorder reads it when inverting.
    # @parameter options [Hash] any of {SERVER_OPTIONS}.
    # @returns [void] nothing happens at all when pgnats is not installed in this database.
    def create_nats_server(name, revert_to: nil, **options)
      # pgnats permits exactly one server on the pgnats_fdw wrapper per database -- its own event trigger raises on a second -- so later changes go through #update_nats_server.
      if ActiveRecordPgnats.database.pgnats_enabled?
        ActiveRecordPgnats.database.create_server(name, _nats_validated_options(options))
      end
    end

    # Changes the server's options to exactly those given.
    #
    # @parameter name [String | Symbol] the server to alter.
    # @parameter revert_to [Hash] the options to restore on rollback; without it the migration is irreversible.
    # @parameter options [Hash] the options the server should end up with. Declarative, not additive: anything left out is dropped.
    # @returns [void]
    def update_nats_server(name, revert_to: nil, **options)
      if ActiveRecordPgnats.database.pgnats_enabled?
        ActiveRecordPgnats.database.update_server(name, _nats_validated_options(options))
      end
    end

    # Drops the server, leaving pgnats unconfigured.
    #
    # @parameter name [String | Symbol] the server to drop.
    # @parameter revert_to [Hash] the options to recreate it with on rollback; without it the migration is irreversible.
    # @returns [void]
    def drop_nats_server(name, revert_to: nil)
      if ActiveRecordPgnats.database.pgnats_enabled?
        ActiveRecordPgnats.database.drop_server(name)
      end
    end

    # Subscribes a Postgres function to a NATS subject.
    #
    # @example
    #   create_nats_subscription "events.user.created", function: "handle_user_created"
    #
    # @parameter subject [String] the NATS subject to subscribe to.
    # @parameter function [String | Symbol] the function the background worker calls. It must exist already and take a single bytea, the message payload.
    # @returns [void]
    def create_nats_subscription(subject, function:)
      # nats_subscribe resolves the name to an OID, so create the function in an earlier migration -- F(x) is the obvious way -- or this fails.
      if ActiveRecordPgnats.database.pgnats_enabled?
        ActiveRecordPgnats.database.create_subscription(subject, function)
      end
    end

    # Unsubscribes the function from the subject.
    #
    # @parameter subject [String] the subject it was subscribed to.
    # @parameter function [String | Symbol] the function to stop calling.
    # @returns [void]
    def drop_nats_subscription(subject, function:)
      if ActiveRecordPgnats.database.pgnats_enabled?
        ActiveRecordPgnats.database.drop_subscription(subject, function)
      end
    end

    # Publishes every row change on a table.
    #
    # @example
    #   create_nats_publish_trigger :maps_devices, subject: "pg_changes.%s.%s"
    #
    # @parameter table [String | Symbol] the table to watch.
    # @parameter subject [String] a format string given the table name and the lowercased operation, so one definition covers insert, update and delete.
    # @parameter revert_to_subject [String] unused here; the command recorder reads it when inverting a drop.
    # @returns [void]
    def create_nats_publish_trigger(table, subject:, revert_to_subject: nil)
      # The function and the trigger are ordinary ones once created, so the schema dumper leaves them alone: F(x) dumps them, and structure.sql carries them either way.
      if ActiveRecordPgnats.database.pgnats_enabled?
        ActiveRecordPgnats.database.create_publish_trigger(table, subject)
      end
    end

    # Drops the publish trigger and its function.
    #
    # @parameter table [String | Symbol] the table it watches.
    # @parameter revert_to_subject [String] the subject to recreate it with on rollback; without it the migration is irreversible.
    # @returns [void]
    def drop_nats_publish_trigger(table, revert_to_subject: nil)
      if ActiveRecordPgnats.database.pgnats_enabled?
        ActiveRecordPgnats.database.drop_publish_trigger(table)
      end
    end

    private

      # Rejects unknown options and stringifies the rest.
      #
      # @parameter options [Hash] the options as the migration wrote them.
      # @returns [Hash] the same options with keys and values as strings, because every FDW option is text.
      # @raises [ArgumentError] when an option is not one pgnats reads: the wrapper's validator accepts a typo that pgnats then ignores.
      def _nats_validated_options(options)
        unknown = options.keys.map(&:to_sym) - SERVER_OPTIONS

        unless unknown.empty?
          message = "unknown pgnats server option(s): #{unknown.join(", ")}. Known options: #{SERVER_OPTIONS.join(", ")}"

          raise ArgumentError, message, caller
        end

        options.to_h { |key, value| [key.to_s, value.to_s] }
      end
  end
end
