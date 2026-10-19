# frozen_string_literal: true

require "rails/railtie"

module ActiveRecordPgnats
  module Rails
    class Railtie < ::Rails::Railtie
      initializer "active_record_pgnats.load" do
        ActiveSupport.on_load :active_record do
          ActiveRecordPgnats.load
        end
      end
    end
  end
end
