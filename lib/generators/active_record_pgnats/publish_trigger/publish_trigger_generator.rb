# frozen_string_literal: true

require "generators/active_record_pgnats/base"

module ActiveRecordPgnats
  module Generators
    # @api private
    class PublishTriggerGenerator < Base
      source_root File.expand_path("templates", __dir__)

      # Given the table name and the lowercased operation, so one subject covers insert, update and delete.
      class_option :subject, type: :string, default: "pg_changes.%s.%s"

      def create_migration_file
        migration_template "db/migrate/create_publish_trigger.erb",
          "db/migrate/create_nats_publish_trigger_#{file_name}.rb"
      end

      no_tasks do
        def formatted_table_name
          format_for_migration(table_name)
        end
      end
    end
  end
end
