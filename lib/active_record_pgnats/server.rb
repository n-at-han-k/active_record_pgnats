# frozen_string_literal: true

module ActiveRecordPgnats
  # pgnats' foreign server as it exists in pg_foreign_server, and how it is
  # written back into schema.rb.
  #
  # @api private
  class Server
    include Comparable

    attr_reader :name, :options

    def initialize(row)
      @name = row.fetch("name")
      @options = self.class.parse_options(row.fetch("options"))
    end

    # srvoptions comes back as a Postgres text[] of "key=value" items, which the
    # pg adapter hands over either as an Array or as the raw "{a=b,c=d}" literal.
    def self.parse_options(value)
      items = value.is_a?(Array) ? value : value.to_s.delete_prefix("{").delete_suffix("}").split(",")

      items.to_h do |item|
        key, _, rest = item.to_s.partition("=")
        [key, rest]
      end
    end

    def <=>(other)
      name <=> other.name
    end

    def ==(other)
      name == other.name && options == other.options
    end

    def to_schema
      <<~SCHEMA.then { |schema| schema.gsub(/^(?=.)/, "  ") }
        create_nats_server :#{name}, #{options.map { |key, value| "#{key}: #{value.inspect}" }.join(", ")}
      SCHEMA
    end
  end
end
