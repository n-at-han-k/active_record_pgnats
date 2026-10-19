# frozen_string_literal: true

require "active_record_pgnats/rails"

RSpec.describe ActiveRecordPgnats::Rails::Railtie do
  it "defers the hooks to an on_load :active_record initializer" do
    initializer = described_class.initializers.find { |each| each.name == "active_record_pgnats.load" }

    expect(initializer).not_to be_nil
  end

  it "carries its own version, separate from the core's" do
    expect(ActiveRecordPgnats::Rails::VERSION).to be_a(String)
    expect(ActiveRecordPgnats::VERSION).to be_a(String)
  end
end
