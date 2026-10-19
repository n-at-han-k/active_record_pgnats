# frozen_string_literal: true

require "active_record"

require "active_record_pgnats/version"
require "active_record_pgnats/adapters/postgres"
require "active_record_pgnats/command_recorder"
require "active_record_pgnats/configuration"
require "active_record_pgnats/publish_trigger"
require "active_record_pgnats/schema_dumper"
require "active_record_pgnats/server"
require "active_record_pgnats/statements"
require "active_record_pgnats/subscription"

# Migration methods for pgnats: the foreign server that holds its connection
# config, the subject subscriptions its background worker reads, and the
# triggers that publish row changes.
#
# No railtie and no Rails: requiring this file installs the hooks, so an
# Active Record app without Rails gets them by requiring the gem.
module ActiveRecordPgnats
  class << self
    def load
      return false if @loaded

      ActiveRecord::ConnectionAdapters::AbstractAdapter.include(Statements)
      ActiveRecord::Migration::CommandRecorder.include(CommandRecorder)
      ActiveRecord::SchemaDumper.prepend(SchemaDumper)

      @loaded = true
    end

    def configuration
      @configuration ||= Configuration.new
    end

    attr_writer :configuration

    def configure
      yield configuration
    end

    def database
      configuration.adapter
    end
  end
end

ActiveRecordPgnats.load
