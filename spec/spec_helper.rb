# frozen_string_literal: true

require "active_record_pgnats"

Dir[File.join(__dir__, "support", "**", "*.rb")].sort.each { |file| require file }

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random

  # Every spec but the integration one talks to a fake adapter, so the suite
  # runs with no database.
  config.around do |example|
    original = ActiveRecordPgnats.configuration
    example.run
    ActiveRecordPgnats.configuration = original
  end
end
