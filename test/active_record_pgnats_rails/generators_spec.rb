# frozen_string_literal: true

require "active_record_pgnats/rails"
require "generators/active_record_pgnats/server/server_generator"
require "generators/active_record_pgnats/subscription/subscription_generator"
require "generators/active_record_pgnats/publish_trigger/publish_trigger_generator"

RSpec.describe "generators" do
  include GeneratorRun

  it "writes a server migration" do
    run_generator(ActiveRecordPgnats::Generators::ServerGenerator, ["nats", "--host=10.0.0.1"]) do |root|
      migration = Dir[File.join(root, "db/migrate/*_create_nats_server_nats.rb")].first

      expect(migration).not_to be_nil
      expect(File.read(migration)).to include('create_nats_server :nats, host: "10.0.0.1", port: "4222"')
    end
  end

  it "writes a subscription migration, with the subject as a string" do
    args = ["events.user.created", "handle_user_created"]

    run_generator(ActiveRecordPgnats::Generators::SubscriptionGenerator, args) do |root|
      migration = Dir[File.join(root, "db/migrate/*_create_nats_subscription_events_user_created.rb")].first

      expect(migration).not_to be_nil
      expect(File.read(migration))
        .to include('create_nats_subscription "events.user.created", function: "handle_user_created"')
    end
  end

  it "writes a publish trigger migration that can be rolled back" do
    args = ["maps_devices", "--subject=devices.%s.%s"]

    run_generator(ActiveRecordPgnats::Generators::PublishTriggerGenerator, args) do |root|
      migration = Dir[File.join(root, "db/migrate/*_create_nats_publish_trigger_maps_devices.rb")].first

      expect(migration).not_to be_nil
      expect(File.read(migration)).to include('create_nats_publish_trigger :maps_devices')
      expect(File.read(migration)).to include('revert_to_subject: "devices.%s.%s"')
    end
  end
end
