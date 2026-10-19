# frozen_string_literal: true

module ActiveRecordPgnats
  class Configuration
    # The adapter statements run through. Defaults to the Postgres adapter over ActiveRecord::Base's own connection: pgnats' foreign server and its subscriptions table live in the application's database, so that is the connection that can see them.
    attr_accessor :adapter

    def initialize(adapter: Adapters::Postgres.new)
      @adapter = adapter
    end
  end
end
