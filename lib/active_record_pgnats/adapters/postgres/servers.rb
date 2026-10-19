# frozen_string_literal: true

require "active_record_pgnats/server"
require "active_record_pgnats/adapters/postgres/query_executor"

module ActiveRecordPgnats
  module Adapters
    class Postgres
      # Fetches pgnats' foreign server from the connection.
      #
      # @api private
      class Servers
        # Selected by wrapper, not by name: the name is the migration's to choose, and pgnats itself joins pg_foreign_data_wrapper on fdwname to find it.
        SERVERS_QUERY = <<~SQL.freeze
          SELECT
              s.srvname AS name,
              s.srvoptions AS options
          FROM pg_foreign_server s
          JOIN pg_foreign_data_wrapper w
              ON w.oid = s.srvfdw
          WHERE w.fdwname = 'pgnats_fdw'
          ORDER BY s.srvname;
        SQL

        def self.all(connection)
          QueryExecutor.call(connection: connection, query: SERVERS_QUERY, model_class: Server)
        end
      end
    end
  end
end
