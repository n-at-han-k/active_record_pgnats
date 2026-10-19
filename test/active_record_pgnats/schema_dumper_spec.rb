# frozen_string_literal: true

RSpec.describe ActiveRecordPgnats::SchemaDumper do
  # Stands in for ActiveRecord::SchemaDumper: all that matters is that #tables
  # is called and that ours runs after it.
  let(:dumper_class) do
    Class.new do
      def tables(stream)
        stream.puts "  create_table :maps_devices"
      end
    end.tap { |klass| klass.prepend(described_class) }
  end

  let(:adapter) do
    instance_double(
      ActiveRecordPgnats::Adapters::Postgres,
      servers: [ActiveRecordPgnats::Server.new("name" => "nats", "options" => ["host=127.0.0.1"])],
      subscriptions: [ActiveRecordPgnats::Subscription.new("subject" => "events.>", "callback" => "handle")]
    )
  end

  before { ActiveRecordPgnats.configuration.adapter = adapter }

  it "dumps the server and its subscriptions after the tables" do
    stream = StringIO.new

    dumper_class.new.tables(stream)

    expect(stream.string).to eq(
      "  create_table :maps_devices\n" \
      "\n  create_nats_server :nats, host: \"127.0.0.1\"\n" \
      "\n  create_nats_subscription \"events.>\", function: \"handle\"\n"
    )
  end
end
