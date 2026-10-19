# frozen_string_literal: true

RSpec.describe ActiveRecordPgnats::CommandRecorder do
  subject(:recorder) { ActiveRecord::Migration::CommandRecorder.new }

  it "records a server creation" do
    recorder.create_nats_server(:nats, host: "127.0.0.1")

    expect(recorder.commands).to eq([[:create_nats_server, [:nats, {host: "127.0.0.1"}], nil]])
  end

  it "reverts a server creation to a drop" do
    recorder.revert { recorder.create_nats_server(:nats, host: "127.0.0.1") }

    expect(recorder.commands).to eq([[:drop_nats_server, [:nats, {host: "127.0.0.1"}]]])
  end

  it "reverts an update to the options it was given to revert to" do
    recorder.revert { recorder.update_nats_server(:nats, host: "10.0.0.1", revert_to: {host: "127.0.0.1"}) }

    expect(recorder.commands).to eq([[:update_nats_server, [:nats, {host: "127.0.0.1"}]]])
  end

  it "reverts a drop to the options it was given to revert to" do
    recorder.revert { recorder.drop_nats_server(:nats, revert_to: {host: "127.0.0.1", port: 4222}) }

    expect(recorder.commands).to eq([[:create_nats_server, [:nats, {host: "127.0.0.1", port: 4222}]]])
  end

  it "refuses to revert an update with nothing to revert to" do
    expect { recorder.revert { recorder.update_nats_server(:nats, host: "10.0.0.1") } }
      .to raise_error(ActiveRecord::IrreversibleMigration, /revert_to/)
  end

  it "reverts a subscription without extra information" do
    recorder.revert { recorder.create_nats_subscription("events.user.created", function: "handle_user_created") }

    expect(recorder.commands)
      .to eq([[:drop_nats_subscription, ["events.user.created", {function: "handle_user_created"}]]])
  end

  it "reverts a dropped subscription back to a creation" do
    recorder.revert { recorder.drop_nats_subscription("events.user.created", function: "handle_user_created") }

    expect(recorder.commands)
      .to eq([[:create_nats_subscription, ["events.user.created", {function: "handle_user_created"}]]])
  end

  it "reverts a publish trigger to a drop" do
    recorder.revert { recorder.create_nats_publish_trigger(:maps_devices, subject: "pg_changes.%s.%s") }

    expect(recorder.commands).to eq([[:drop_nats_publish_trigger, [:maps_devices]]])
  end

  it "reverts a dropped publish trigger only with a subject to restore" do
    recorder.revert { recorder.drop_nats_publish_trigger(:maps_devices, revert_to_subject: "pg_changes.%s.%s") }

    expect(recorder.commands)
      .to eq([[:create_nats_publish_trigger, [:maps_devices, {subject: "pg_changes.%s.%s"}]]])
  end

  it "refuses to revert a dropped publish trigger with no subject" do
    expect { recorder.revert { recorder.drop_nats_publish_trigger(:maps_devices) } }
      .to raise_error(ActiveRecord::IrreversibleMigration, /revert_to_subject/)
  end
end
