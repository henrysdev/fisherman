defmodule FishermanServer.ShellRecord do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  schema "shell_records" do
    field :command, :string
    field :command_timestamp, :naive_datetime
    field :error, :string
    field :error_timestamp, :naive_datetime
    field :user_id, Ecto.UUID
    field :pid, :string

    timestamps()
  end

  @doc false
  def changeset(shell_records, attrs) do
    shell_records
    |> cast(attrs, [
      :user_id,
      :command,
      :error,
      :command_timestamp,
      :error_timestamp,
      :pid
    ])
    |> validate_required([
      :user_id,
      :command,
      :error,
      :command_timestamp,
      :error_timestamp,
      :pid
    ])
  end
end
