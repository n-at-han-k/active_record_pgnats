# frozen_string_literal: true

RSpec.describe ActiveRecordPgnats::Statements do
  subject(:connection) { FakeConnection.new }

  let(:adapter) { FakeAdapter.new }

  before { ActiveRecordPgnats.configuration.adapter = adapter }

  describe "#create_nats_server" do
    it "passes the options through as strings" do
      connection.create_nats_server(:nats, host: "127.0.0.1", port: 4222)

      expect(adapter.calls).to eq([[:create_server, :nats, {"host" => "127.0.0.1", "port" => "4222"}]])
    end

    it "rejects an option pgnats does not read" do
      expect { connection.create_nats_server(:nats, hsot: "127.0.0.1") }
        .to raise_error(ArgumentError, /unknown pgnats server option\(s\): hsot/)
    end

    it "does nothing when pgnats is not installed" do
      ActiveRecordPgnats.configuration.adapter = FakeAdapter.new(enabled: false)

      connection.create_nats_server(:nats, host: "127.0.0.1")

      expect(ActiveRecordPgnats.database.calls).to be_empty
    end
  end

  describe "#update_nats_server" do
    it "does not pass revert_to on to the database" do
      connection.update_nats_server(:nats, host: "10.0.0.1", revert_to: {host: "127.0.0.1"})

      expect(adapter.calls).to eq([[:update_server, :nats, {"host" => "10.0.0.1"}]])
    end
  end

  describe "#create_nats_subscription" do
    it "subscribes the function to the subject" do
      connection.create_nats_subscription("events.user.created", function: "handle_user_created")

      expect(adapter.calls).to eq([[:create_subscription, "events.user.created", "handle_user_created"]])
    end
  end

  describe "#create_nats_publish_trigger" do
    it "passes the table and subject format" do
      connection.create_nats_publish_trigger(:maps_devices, subject: "pg_changes.%s.%s")

      expect(adapter.calls).to eq([[:create_publish_trigger, :maps_devices, "pg_changes.%s.%s"]])
    end
  end
end
