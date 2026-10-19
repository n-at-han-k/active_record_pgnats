# frozen_string_literal: true

module ActiveRecordPgnats
  # Makes the statements reversible.
  module CommandRecorder
    %i[
      create_nats_server update_nats_server drop_nats_server
      create_nats_subscription drop_nats_subscription
      create_nats_publish_trigger drop_nats_publish_trigger
    ].each do |statement|
      define_method(statement) do |*args, &block|
        record(statement, args, &block)
      end
      ruby2_keywords statement
    end

    # Inverts a server creation.
    #
    # @parameter args [Array] the recorded arguments.
    # @returns [Array] the statement to run instead, and its arguments. A subscription inverts on its own, subject plus function being the whole of it; the server does not, its options being the definition, so a migration that drops or rewrites them has to say what to go back to.
    def invert_create_nats_server(args)
      [:drop_nats_server, args]
    end

    def invert_drop_nats_server(args)
      _nats_invert_server(:create_nats_server, args)
    end

    def invert_update_nats_server(args)
      _nats_invert_server(:update_nats_server, args)
    end

    def invert_create_nats_subscription(args)
      [:drop_nats_subscription, args]
    end

    def invert_drop_nats_subscription(args)
      [:create_nats_subscription, args]
    end

    def invert_create_nats_publish_trigger(args)
      [:drop_nats_publish_trigger, [args.first]]
    end

    def invert_drop_nats_publish_trigger(args)
      name, options = args
      subject = (options || {})[:revert_to_subject]

      unless subject
        raise ActiveRecord::IrreversibleMigration,
          "`drop_nats_publish_trigger` is reversible only if given a `revert_to_subject`"
      end

      [:create_nats_publish_trigger, [name, Hash.ruby2_keywords_hash({subject: subject})]]
    end

    private

      def _nats_invert_server(method, args)
        name, options = args
        revert_to = (options || {})[:revert_to]

        unless revert_to
          raise ActiveRecord::IrreversibleMigration,
            "`#{method}` is reversible only if given a `revert_to`"
        end

        [method, [name, Hash.ruby2_keywords_hash(revert_to.to_h)]]
      end
  end
end
