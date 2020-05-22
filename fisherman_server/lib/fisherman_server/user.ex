defmodule FishermanServer.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  schema "users" do
    field :email, :string
    field :machine_serial, :string
    field :name, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :username, :machine_serial])
    |> validate_required([:name, :email, :username, :machine_serial])
  end
end
