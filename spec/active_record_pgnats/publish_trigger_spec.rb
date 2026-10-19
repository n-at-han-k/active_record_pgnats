# frozen_string_literal: true

RSpec.describe ActiveRecordPgnats::PublishTrigger do
  describe ".sql" do
    subject(:sql) { described_class.sql(table: :maps_devices, subject: "pg_changes.%s.%s") }

    it "names the function and the trigger after the table" do
      expect(sql).to include("CREATE OR REPLACE FUNCTION nats_publish_maps_devices()")
      expect(sql).to include("CREATE TRIGGER nats_publish_maps_devices")
      expect(sql).to include("AFTER INSERT OR UPDATE OR DELETE ON maps_devices")
    end

    it "publishes OLD on a delete and NEW otherwise" do
      expect(sql).to include("IF TG_OP = 'DELETE' THEN\n    payload := to_jsonb(OLD);")
      expect(sql).to include("payload := to_jsonb(NEW);")
    end

    it "swallows publish errors so the write still commits" do
      expect(sql).to include("EXCEPTION WHEN OTHERS THEN")
    end

    it "quotes the subject format" do
      expect(described_class.sql(table: :t, subject: "a.%s.%s'; DROP"))
        .to include("format('a.%s.%s''; DROP', TG_TABLE_NAME, lower(TG_OP))")
    end
  end

  describe ".drop_sql" do
    it "drops the trigger and its function" do
      expect(described_class.drop_sql(table: :maps_devices)).to eq(<<~SQL)
        DROP TRIGGER IF EXISTS nats_publish_maps_devices ON maps_devices;
        DROP FUNCTION IF EXISTS nats_publish_maps_devices();
      SQL
    end
  end
end
