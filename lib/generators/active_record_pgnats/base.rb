# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module ActiveRecordPgnats
  module Generators
    # Shared plumbing for the three generators.
    #
    # @api private
    class Base < ::Rails::Generators::NamedBase
      include ::Rails::Generators::Migration

      # Numbers a migration as Active Record's own generators do.
      #
      # @parameter dir [String] the migration directory.
      # @returns [String] the next migration's number.
      def self.next_migration_number(dir)
        ::ActiveRecord::Generators::Base.next_migration_number(dir)
      end

      no_tasks do
        # Writes a name as the migration should spell it.
        #
        # @parameter name [String | Symbol] the name to spell.
        # @returns [String] a symbol literal, or a string literal when the name is no valid symbol -- a subject or anything else carrying dots.
        def format_for_migration(name)
          name.to_s.match?(/\A[a-z_][a-z0-9_]*\z/) ? ":#{name}" : name.to_s.inspect
        end
      end
    end
  end
end
