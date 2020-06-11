defmodule FishermanServerWeb.UserController do
  @moduledoc """
  Resource controller for User model.
  """
  use FishermanServerWeb, :controller

  alias FishermanServer.{
    Repo,
    User
  }

  @doc """
  Creates and inserts a new user object
  """
  def create(conn, params) do
    user =
      %User{}
      |> User.changeset(params)
      |> Repo.insert!()
      |> unmarshal()

    json(conn, user)
  end

  defp unmarshal(user = %User{}) do
    %{
      username: user.username,
      email: user.email,
      machine_serial: user.machine_serial,
      first_name: user.first_name,
      last_name: user.last_name,
      user_id: user.uuid
    }
  end
end
