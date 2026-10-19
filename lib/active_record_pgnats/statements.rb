# frozen_string_literal: true

module ActiveRecordPgnats
  # The migration DSL.
  #
  # Every public name here is prefixed `nats_` or `_nats_`, including the
  # private helpers. That is load-bearing rather than tidy: this module and
  # F(x)'s Statements are both included into ActiveRecord::ConnectionAdapters::
  # AbstractAdapter, so a helper sharing a name with one of F(x)'s shadows it
  # for every migration in the application.
  module Statements
    # The options pgnats reads off its foreign server. A typo in one is accepted
    # by Postgres' validator only to be ignored by pgnats, so it is rejected here.
    SERVER_OPTIONS = %i[
      host port capacity tls_ca_path tls_cert_path tls_key_path notify_subject patroni_url
    ].freeze

    # Create pgnats' foreign server, which is the whole of its configuration.
    #
    # pgnats permits exactly one server on the pgnats_fdw wrapper per database
    # (its own event trigger raises on a second), so this runs once and later
    # changes go through {#update_nats_server}.
    #
    # @example
    #   create_nats_server :nats, host: "127.0.0.1", port: 4222
    def create_nats_server(name, revert_to: nil, **options)
      return unless ActiveRecordPgnats.database.pgnats_enabled?

      ActiveRecordPgnats.database.create_server(name, _nats_validated_options(options))
    end

    # Change the server's options to exactly those given.
    #
    # Declarative, not additive: an option left out of the hash is DROPped from
    # the server. The adapter diffs against the catalog to pick SET / ADD / DROP,
    # because ALTER SERVER rejects SET for an option that is not there and ADD
    # for one that is.
    #
    # @param revert_to [Hash] the options to restore on rollback
    def update_nats_server(name, revert_to: nil, **options)
      return unless ActiveRecordPgnats.database.pgnats_enabled?

      ActiveRecordPgnats.database.update_server(name, _nats_validated_options(options))
    end

    # @param revert_to [Hash] the options to recreate the server with on rollback
    def drop_nats_server(name, revert_to: nil)
      return unless ActiveRecordPgnats.database.pgnats_enabled?

      ActiveRecordPgnats.database.drop_server(name)
    end

    # Subscribe a Postgres function to a NATS subject.
    #
    # The function must already exist and must take a single bytea, which is the
    # message payload. Create it in an earlier migration (F(x) is the obvious
    # way) -- nats_subscribe resolves the name to an OID and fails if it is not
    # there.
    #
    # @example
    #   create_nats_subscription "events.user.created", function: "handle_user_created"
    def create_nats_subscription(subject, function:)
      return unless ActiveRecordPgnats.database.pgnats_enabled?

      ActiveRecordPgnats.database.create_subscription(subject, function)
    end

    def drop_nats_subscription(subject, function:)
      return unless ActiveRecordPgnats.database.pgnats_enabled?

      ActiveRecordPgnats.database.drop_subscription(subject, function)
    end

    # Publish every row change on a table to NATS.
    #
    # Writes the trigger function and the trigger, both named after the table.
    # `subject` is a format string given the table name and the lowercased
    # operation, so one definition covers insert, update and delete.
    #
    # These are an ordinary function and trigger once created, so this gem's
    # schema dumper does not emit them -- F(x) dumps them as create_function and
    # create_trigger, and structure.sql carries them either way.
    #
    # @example
    #   create_nats_publish_trigger :maps_devices, subject: "pg_changes.%s.%s"
    def create_nats_publish_trigger(table, subject:, revert_to_subject: nil)
      return unless ActiveRecordPgnats.database.pgnats_enabled?

      ActiveRecordPgnats.database.create_publish_trigger(table, subject)
    end

    # @param revert_to_subject [String] the subject to recreate the trigger with on rollback
    def drop_nats_publish_trigger(table, revert_to_subject: nil)
      return unless ActiveRecordPgnats.database.pgnats_enabled?

      ActiveRecordPgnats.database.drop_publish_trigger(table)
    end

    private

    def _nats_validated_options(options)
      unknown = options.keys.map(&:to_sym) - SERVER_OPTIONS

      unless unknown.empty?
        raise ArgumentError, "unknown pgnats server option(s): #{unknown.join(", ")}. " \
                             "Known options: #{SERVER_OPTIONS.join(", ")}", caller
      end

      # Every FDW option is text; `port: 4222` would otherwise be a type error
      # from the wrapper's validator rather than from here.
      options.to_h { |key, value| [key.to_s, value.to_s] }
    end
  end
end
