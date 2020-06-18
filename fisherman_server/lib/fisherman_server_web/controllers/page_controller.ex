defmodule FishermanServerWeb.PageController do
  use FishermanServerWeb, :controller
  import Phoenix.LiveView.Controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  @doc """
  Renders linear
  """
  def shellfeed(conn, %{"user_id" => user_id, "view" => view}) do
    history_buffer = DateTime.utc_now() |> DateTime.add(-10, :second)

    case view do
      _linear ->
        live_render(conn, FishermanServerWeb.Live.LinearShellsTable,
          session: %{
            "user_id" => user_id,
            "from_ts" => history_buffer
          }
        )
    end
  end

  def shellfeed(conn, _params) do
    render(conn, "index.html")
  end
end
