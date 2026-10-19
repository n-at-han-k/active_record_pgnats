# frozen_string_literal: true

module ActiveRecordPgnats
  # Builds the SQL for a trigger that publishes row changes to NATS.
  #
  # @api private
  module PublishTrigger
    module_function

    def name_for(table)
      "nats_publish_#{table}"
    end

    def sql(table:, subject:, name: nil)
      name ||= name_for(table)

      <<~SQL
        CREATE OR REPLACE FUNCTION #{name}() RETURNS trigger
        LANGUAGE plpgsql AS $pgnats$
        DECLARE
          payload jsonb;
        BEGIN
          IF TG_OP = 'DELETE' THEN
            payload := to_jsonb(OLD);
          ELSE
            payload := to_jsonb(NEW);
          END IF;

          -- A NATS problem must never roll back the write that fired the trigger.
          BEGIN
            PERFORM nats_publish_json_stream(
              format(#{quote(subject)}, TG_TABLE_NAME, lower(TG_OP)),
              json_build_object('table', TG_TABLE_NAME, 'op', TG_OP, 'at', now(), 'row', payload)
            );
          EXCEPTION WHEN OTHERS THEN
            NULL;
          END;

          RETURN NULL;
        END
        $pgnats$;

        DROP TRIGGER IF EXISTS #{name} ON #{table};

        CREATE TRIGGER #{name}
          AFTER INSERT OR UPDATE OR DELETE ON #{table}
          FOR EACH ROW EXECUTE FUNCTION #{name}();
      SQL
    end

    def drop_sql(table:, name: nil)
      name ||= name_for(table)

      <<~SQL
        DROP TRIGGER IF EXISTS #{name} ON #{table};
        DROP FUNCTION IF EXISTS #{name}();
      SQL
    end

    def quote(value)
      "'#{value.to_s.gsub("'", "''")}'"
    end
  end
end
