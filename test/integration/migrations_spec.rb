# frozen_string_literal: true

# Runs only against a real database with pgnats installed:
#   DATABASE_URL=postgres:///opencloud-api bundle exec rspec spec/integration
RSpec.describe "migrations", :integration do
  before(:all) do
    unless ENV["DATABASE_URL"]
      skip "set DATABASE_URL to run the integration spec"
    end

    require "pg"
    ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
    unless ActiveRecordPgnats.database.pgnats_enabled?
      skip "pgnats is not installed in #{ENV["DATABASE_URL"]}"
    end
  end

  let(:connection) { ActiveRecord::Base.connection }

  it "creates, updates and drops the server" do
    existing = ActiveRecordPgnats.database.servers.map(&:name)
    if existing.any?
      skip "a pgnats server already exists (#{existing.join(", ")}); only one is allowed"
    end

    connection.create_nats_server(:nats_spec, host: "127.0.0.1", port: 4222)
    expect(ActiveRecordPgnats.database.servers.map(&:options))
      .to eq([{"host" => "127.0.0.1", "port" => "4222"}])

    connection.update_nats_server(:nats_spec, host: "127.0.0.1", capacity: 256)
    expect(ActiveRecordPgnats.database.servers.first.options)
      .to eq("host" => "127.0.0.1", "capacity" => "256")

    connection.drop_nats_server(:nats_spec)
    expect(ActiveRecordPgnats.database.servers).to be_empty
  end

  it "round-trips a publish trigger" do
    connection.execute("CREATE TABLE IF NOT EXISTS pgnats_spec_rows (id serial primary key, name text)")
    connection.create_nats_publish_trigger(:pgnats_spec_rows, subject: "pg_changes.%s.%s")

    expect { connection.execute("INSERT INTO pgnats_spec_rows (name) VALUES ('a')") }.not_to raise_error

    connection.drop_nats_publish_trigger(:pgnats_spec_rows)
    connection.execute("DROP TABLE pgnats_spec_rows")
  end
end
