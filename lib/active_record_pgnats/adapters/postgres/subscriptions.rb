# frozen_string_literal: true

require "active_record_pgnats/subscription"
require "active_record_pgnats/adapters/postgres/query_executor"

module ActiveRecordPgnats
  module Adapters
    class Postgres
      # Fetches subscriptions from pgnats' own table.
      #
      # @api private
      class Subscriptions
        # pgnats.subscriptions is the durable state its worker reads on start, so there is no catalog view to read instead.
        SUBSCRIPTIONS_QUERY = <<~SQL.freeze
          SELECT subject, callback
          FROM pgnats.subscriptions
          ORDER BY subject, callback;
        SQL

        def self.all(connection)
          QueryExecutor.call(connection: connection, query: SUBSCRIPTIONS_QUERY, model_class: Subscription)
        end
      end
    end
  end
end
