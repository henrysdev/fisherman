defmodule FishermanServer.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    create table(:users) do
      add :uuid, :uuid, null: false
      add :first_name, :string, null: false
      add :last_name, :string
      add :email, :string, null: false
      add :username, :string, null: false
      add :machine_serial, :string

      timestamps()
    end

    alter table(:users) do
      remove(:id)
      modify(:uuid, :uuid, primary_key: true)
    end
  end

  def down do
    drop table(:users)
  end
end
