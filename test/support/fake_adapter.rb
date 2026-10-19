# frozen_string_literal: true

# Records what the statements asked the database to do.
class FakeAdapter
  attr_reader :calls

  def initialize(enabled: true)
    @enabled = enabled
    @calls = []
  end

  def pgnats_enabled?
    @enabled
  end

  %i[
    create_server update_server drop_server
    create_subscription drop_subscription
    create_publish_trigger drop_publish_trigger
  ].each do |method|
    define_method(method) do |*args|
      @calls << [method, *args]
      nil
    end
  end

  def servers
    []
  end

  def subscriptions
    []
  end
end

# A bare object carrying the statements.
class FakeConnection
  include ActiveRecordPgnats::Statements
end
