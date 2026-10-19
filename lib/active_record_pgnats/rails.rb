# frozen_string_literal: true

require "active_record_pgnats"
require "active_record_pgnats/rails/version"
require "active_record_pgnats/rails/railtie"

module ActiveRecordPgnats
  # Rails integration: the railtie that installs the hooks at the right moment,
  # and the generators that write the migrations.
  #
  # The core gem installs its hooks when required, because outside Rails there
  # is no later moment to wait for. In a Rails application there is -- Active
  # Record may not be loaded when the bundle is -- so the core defers to the
  # railtie here instead.
  module Rails
  end
end
