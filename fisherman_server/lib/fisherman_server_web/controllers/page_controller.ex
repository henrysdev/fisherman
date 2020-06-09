defmodule FishermanServerWeb.PageController do
  use FishermanServerWeb, :controller
  import Phoenix.LiveView.Controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  @doc """
  Renders live view shell activity feed for the given user
  """
  def shellfeed(conn, %{"user_id" => user_id}) do
    live_render(conn, FishermanServerWeb.ShellFeedLive,
      session: %{
        "user_id" => user_id,
        "from_ts" => DateTime.utc_now() |> DateTime.add(-10, :second)
      }
    )
  end

  def shellfeed(conn, _params) do
    render(conn, "index.html")
  end
end
