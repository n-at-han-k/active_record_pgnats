# frozen_string_literal: true

module ActiveRecordPgnats
  # A row of pgnats.subscriptions: a subject and its function.
  #
  # @api private
  class Subscription
    include Comparable

    attr_reader :subject, :function

    def initialize(row)
      @subject = row.fetch("subject")
      @function = row.fetch("callback")
    end

    def <=>(other)
      [subject, function] <=> [other.subject, other.function]
    end

    def ==(other)
      subject == other.subject && function == other.function
    end

    def to_schema
      <<~SCHEMA.then { |schema| schema.gsub(/^(?=.)/, "  ") }
        create_nats_subscription #{subject.inspect}, function: #{function.inspect}
      SCHEMA
    end
  end
end
