# frozen_string_literal: true

RSpec.describe ActiveRecordPgnats::Server do
  it "parses srvoptions given as an array" do
    server = described_class.new("name" => "nats", "options" => ["host=127.0.0.1", "port=4222"])

    expect(server.options).to eq("host" => "127.0.0.1", "port" => "4222")
  end

  it "parses srvoptions given as a text[] literal" do
    server = described_class.new("name" => "nats", "options" => "{host=127.0.0.1,port=4222}")

    expect(server.options).to eq("host" => "127.0.0.1", "port" => "4222")
  end

  it "keeps a value containing an = sign intact" do
    server = described_class.new("name" => "nats", "options" => ["notify_subject=a=b"])

    expect(server.options).to eq("notify_subject" => "a=b")
  end

  it "dumps itself as a create_nats_server line" do
    server = described_class.new("name" => "nats", "options" => ["host=127.0.0.1", "port=4222"])

    expect(server.to_schema).to eq(%(  create_nats_server :nats, host: "127.0.0.1", port: "4222"\n))
  end
end
