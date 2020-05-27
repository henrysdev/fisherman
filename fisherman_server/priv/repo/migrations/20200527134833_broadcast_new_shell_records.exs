defmodule FishermanServer.Repo.Migrations.BroadcastNewShellRecords do
  use Ecto.Migration

  def up do
    # Create a function that broadcasts row changes
    execute "
      CREATE OR REPLACE FUNCTION broadcast_changes()
      RETURNS trigger AS $$
      DECLARE
        current_row RECORD;
      BEGIN
        IF (TG_OP = 'INSERT') THEN
          current_row := NEW;
        END IF;
      PERFORM pg_notify(
          'shell_record_inserts',
          json_build_object(
            'table', TG_TABLE_NAME,
            'type', TG_OP,
            'uuid', current_row.uuid,
            'new_row_data', row_to_json(NEW)
          )::text
        );
      RETURN current_row;
      END;
      $$ LANGUAGE plpgsql;"

    # Create a trigger links the shell_records table to the broadcast function
    execute "
      CREATE TRIGGER notify_shell_record_inserts_trigger
      AFTER INSERT
      ON shell_records
      FOR EACH ROW
      EXECUTE PROCEDURE broadcast_changes();"
  end

  def down do
    execute "DROP TRIGGER notify_shell_record_inserts_trigger ON shell_records;"
  end
end
