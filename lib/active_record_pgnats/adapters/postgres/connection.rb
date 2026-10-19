# frozen_string_literal: true

require "delegate"

module ActiveRecordPgnats
  module Adapters
    class Postgres
      # Decorates an Active Record connection with the one capability every
      # caller needs to know: whether pgnats is installed here at all.
      #
      # Nothing pgnats owns -- the wrapper, the functions, pgnats.subscriptions --
      # exists until CREATE EXTENSION has run, and that additionally needs pgnats
      # in shared_preload_libraries and a restart. Checking first means a
      # migration or a schema dump against a database without it is a no-op
      # rather than an error.
      #
      # @api private
      class Connection < SimpleDelegator
        def pgnats_enabled?
          extension_enabled?("pgnats")
        end
      end
    end
  end
end
