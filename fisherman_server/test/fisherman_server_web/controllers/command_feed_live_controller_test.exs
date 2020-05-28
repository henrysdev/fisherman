defmodule FishermanServerWeb.CommandFeedLiveControllerTest do
  use FishermanServerWeb.ConnCase

  test "GET /cmdfeed", %{conn: conn} do
    conn = get(conn, "/cmdfeed")
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end

  test "GET /cmdfeed with query params", %{conn: conn} do
    conn =
      get(conn, "/cmdfeed", %{
        "user_id" => "abc123",
        "from_ts" => 1_590_655_333_769
      })

    assert html_response(conn, 200) =~ "time (UTC)"
  end
end
