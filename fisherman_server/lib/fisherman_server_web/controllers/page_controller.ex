defmodule FishermanServerWeb.PageController do
  use FishermanServerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
