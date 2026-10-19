# frozen_string_literal: true

RSpec.describe ActiveRecordPgnats::Subscription do
  subject(:subscription) do
    described_class.new("subject" => "events.user.created", "callback" => "handle_user_created")
  end

  it "reads pgnats.subscriptions' own column names" do
    expect(subscription.subject).to eq("events.user.created")
    expect(subscription.function).to eq("handle_user_created")
  end

  it "dumps itself as a create_nats_subscription line" do
    expect(subscription.to_schema)
      .to eq(%(  create_nats_subscription "events.user.created", function: "handle_user_created"\n))
  end
end
