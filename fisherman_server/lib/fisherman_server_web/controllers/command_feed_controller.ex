defmodule FishermanServerWeb.CommandFeedController do
  use FishermanServerWeb, :controller
  import Phoenix.LiveView.Controller

  # Live tail view for user initialized w/ 24 hours historical shell data
  def index(conn, %{"user_id" => user_id, "from_ts" => from_ts}) do
    # TODO do initial historical query for last 24 hours, then start subscribing to a livetail broker
    # for the given user
    live_render(conn, FishermanServerWeb.CommandFeedLive,
      session: %{
        "user_id" => user_id,
        "from_ts" => from_ts
      }
    )
  end

  # If nothing specified, just render default
  def index(conn, _) do
    render(conn, "index.html")
  end
end