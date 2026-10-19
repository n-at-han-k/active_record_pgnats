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

# Migration methods for pgnats, Active Record only.
module ActiveRecordPgnats
  class << self
    # Installs the statements, the recorder and the dumper.
    #
    # @returns [Boolean] true the first time, false once the hooks are in place.
    def load
      if @loaded
        false
      else
        ActiveRecord::ConnectionAdapters::AbstractAdapter.include(Statements)
        ActiveRecord::Migration::CommandRecorder.include(CommandRecorder)
        ActiveRecord::SchemaDumper.prepend(SchemaDumper)
        @loaded = true
      end
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

unless defined?(::Rails::Railtie)
  ActiveRecordPgnats.load
end
