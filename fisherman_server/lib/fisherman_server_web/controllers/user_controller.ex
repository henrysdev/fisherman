defmodule FishermanServerWeb.UserController do
  use FishermanServerWeb, :controller

  alias FishermanServer.{
    Repo,
    User
  }

  def create(conn, params) do
    user = handle_user(params)
    json(conn, user)
  end

  defp handle_user(user) do
    {:ok, user} =
      user
      |> marshal()
      |> Repo.insert()

    unmarshal(user)
  end

  defp marshal(user = %{}) do
    %User{
      username: get_in(user, ["username"]),
      email: get_in(user, ["email"]),
      machine_serial: get_in(user, ["machine_serial"]),
      first_name: get_in(user, ["first_name"]),
      last_name: get_in(user, ["last_name"])
    }
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
