# frozen_string_literal: true

module ActiveRecordPgnats
  module Adapters
    class Postgres
      # Runs a query and maps its rows to domain objects.
      # @api private
      class QueryExecutor
        def self.call(...)
          new(...).call
        end

        def initialize(connection:, query:, model_class:)
          @connection = connection
          @query = query
          @model_class = model_class
        end

        def call
          connection.execute(query).map { |row| model_class.new(row) }
        end

        private

          attr_reader :connection, :query, :model_class
      end
    end
  end
end
