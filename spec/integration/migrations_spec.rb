# frozen_string_literal: true

# Runs only against a real database with pgnats installed:
#   DATABASE_URL=postgres:///opencloud-api bundle exec rspec spec/integration
RSpec.describe "migrations", :integration do
  before(:all) do
    skip "set DATABASE_URL to run the integration spec" unless ENV["DATABASE_URL"]

    require "pg"
    ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
    skip "pgnats is not installed in #{ENV["DATABASE_URL"]}" unless ActiveRecordPgnats.database.pgnats_enabled?
  end

  let(:connection) { ActiveRecord::Base.connection }

  it "creates, updates and drops the server" do
    existing = ActiveRecordPgnats.database.servers.map(&:name)
    skip "a pgnats server already exists (#{existing.join(", ")}); only one is allowed" if existing.any?

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
