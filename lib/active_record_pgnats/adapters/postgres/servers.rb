# frozen_string_literal: true

require "active_record_pgnats/server"
require "active_record_pgnats/adapters/postgres/query_executor"

module ActiveRecordPgnats
  module Adapters
    class Postgres
      # Fetches pgnats' foreign server from the connection.
      #
      # Selected by wrapper rather than by name: the server's name is the
      # migration's to choose, pgnats finds it by joining pg_foreign_data_wrapper
      # on fdwname, and so does this.
      #
      # @api private
      class Servers
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
