defmodule FishermanServer.Repo.Migrations.CreateShellRecords do
  use Ecto.Migration

  def up do
    create table(:shell_records) do
      add :uuid, :uuid, null: false
      add :user_id, references(:users, column: :uuid, type: :uuid), null: false
      add :command, :string, null: false
      add :error, :string
      add :command_timestamp, :utc_datetime_usec, null: false
      add :error_timestamp, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    alter table(:shell_records) do
      remove(:id)
      modify(:uuid, :uuid, primary_key: true)
    end
  end

  def down do
    drop table(:shell_records)
  end
end
