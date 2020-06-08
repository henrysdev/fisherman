defmodule FishermanServerWeb.ShellFeedController do
  use FishermanServerWeb, :controller
  import Phoenix.LiveView.Controller

  # Live tail view for user
  def index(conn, %{"user_id" => user_id}) do
    live_render(conn, FishermanServerWeb.ShellFeedLive,
      session: %{
        "user_id" => user_id,
        "from_ts" => DateTime.utc_now() |> DateTime.add(-10, :second)
      }
    )
  end

  # If nothing specified, just render default
  def index(conn, _) do
    render(conn, "index.html")
  end
end
