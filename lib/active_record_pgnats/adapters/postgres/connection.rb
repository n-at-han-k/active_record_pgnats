# frozen_string_literal: true

require "delegate"

module ActiveRecordPgnats
  module Adapters
    class Postgres
      # Answers whether pgnats is installed in this database.
      #
      # @api private
      class Connection < SimpleDelegator
        # Whether the extension is there to be used.
        #
        # @returns [Boolean] false until CREATE EXTENSION has run, which additionally needs pgnats in shared_preload_libraries and a restart. Every caller checks first, so a migration or a dump against a database without it is a no-op rather than an error.
        def pgnats_enabled?
          extension_enabled?("pgnats")
        end
      end
    end
  end
end
