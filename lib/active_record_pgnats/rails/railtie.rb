# frozen_string_literal: true

require "rails/railtie"

module ActiveRecordPgnats
  module Rails
    class Railtie < ::Rails::Railtie
      # The core installs its hooks on require, because outside Rails there is no later moment to wait for. In a Rails application there is -- Active Record may not be loaded when the bundle is -- so the core defers to this.
      initializer "active_record_pgnats.load" do
        ActiveSupport.on_load :active_record do
          ActiveRecordPgnats.load
        end
      end
    end
  end
end
