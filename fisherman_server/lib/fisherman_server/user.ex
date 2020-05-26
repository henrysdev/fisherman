defmodule FishermanServer.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  schema "users" do
    field :email, :string
    field :machine_serial, :string
    field :first_name, :string
    field :last_name, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :username, :machine_serial])
    |> validate_required([:first_name, :last_name, :email, :username, :machine_serial])
  end
end
