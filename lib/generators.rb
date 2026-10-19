# frozen_string_literal: true

module ActiveRecordPgnats
  # Generators for the pgnats migrations.
  #
  # @example
  #   rails generate active_record_pgnats:server nats
  #   rails generate active_record_pgnats:subscription events.user.created handle_user_created
  #   rails generate active_record_pgnats:publish_trigger maps_devices
  module Generators
  end
end
