# frozen_string_literal: true

require "generators/active_record_pgnats/base"

module ActiveRecordPgnats
  module Generators
    # @api private
    class SubscriptionGenerator < Base
      source_root File.expand_path("templates", __dir__)

      # The subject is the generator's NAME argument; the function it calls is required, because a subscription without one has nothing to run.
      argument :function, type: :string, required: true

      def create_migration_file
        migration_template "db/migrate/create_subscription.erb",
          "db/migrate/create_nats_subscription_#{file_name}.rb"
      end

      no_tasks do
        def subject
          name
        end

        # The subject, with its dots as underscores.
        #
        # @returns [String] the stem of the migration's filename, where a dot would read as an extension.
        def file_name
          super.tr(".", "_")
        end
      end
    end
  end
end
