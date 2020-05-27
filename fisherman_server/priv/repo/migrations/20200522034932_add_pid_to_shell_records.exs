defmodule FishermanServer.Repo.Migrations.AddPidToShellRecords do
  use Ecto.Migration

  def up do
    alter table(:shell_records) do
      add :pid, :string, null: false
    end
  end

  def down do
    alter table(:shell_records) do
      remove :pid
    end
  end
end
