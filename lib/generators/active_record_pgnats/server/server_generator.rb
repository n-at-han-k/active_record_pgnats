# frozen_string_literal: true

require "generators/active_record_pgnats/base"

module ActiveRecordPgnats
  module Generators
    # @api private
    class ServerGenerator < Base
      source_root File.expand_path("templates", __dir__)

      class_option :host, type: :string, default: "127.0.0.1"
      class_option :port, type: :string, default: "4222"

      def create_migration_file
        migration_template "db/migrate/create_server.erb", "db/migrate/create_nats_server_#{file_name}.rb"
      end

      no_tasks do
        def formatted_name
          format_for_migration(singular_name)
        end
      end
    end
  end
end
