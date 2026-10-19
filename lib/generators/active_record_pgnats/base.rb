# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module ActiveRecordPgnats
  module Generators
    # Shared plumbing for the three generators: a migration into db/migrate,
    # numbered the way Active Record's own generators number theirs.
    #
    # @api private
    class Base < ::Rails::Generators::NamedBase
      include ::Rails::Generators::Migration

      def self.next_migration_number(dir)
        ::ActiveRecord::Generators::Base.next_migration_number(dir)
      end

      no_tasks do
        # A subject or a dotted name is not a valid symbol literal, so it is
        # written as a string.
        def format_for_migration(name)
          name.to_s.match?(/\A[a-z_][a-z0-9_]*\z/) ? ":#{name}" : name.to_s.inspect
        end
      end
    end
  end
end
