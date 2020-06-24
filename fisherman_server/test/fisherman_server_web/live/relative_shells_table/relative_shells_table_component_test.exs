defmodule FishermanServerWeb.RelativeShellsTableComponentTest do
  use FishermanServerWeb.ConnCase
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  import FishermanServer.TestFns
  alias FishermanServer.Utils

  test "disconnected and connected mount", %{conn: conn} do
    %{uuid: user_id} = add_user!()
    start_time = Utils.encode_url_datetime()

    {:ok, _view, _html} = live(conn, "history?user_id=#{user_id}&start_time=#{start_time}")
  end

  test "no session error on mount", %{conn: conn} do
    assert {:error, :nosession} = live(conn, "shellfeed")
  end
end
