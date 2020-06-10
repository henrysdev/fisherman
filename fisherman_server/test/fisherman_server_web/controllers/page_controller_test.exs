defmodule FishermanServerWeb.PageControllerTest do
  use FishermanServerWeb.ConnCase
  import FishermanServer.TestFns

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end

  test "GET /shellfeed linear feed", %{conn: conn} do
    user = add_user!()

    conn =
      get(conn, "/shellfeed", %{
        "user_id" => user.uuid,
        "view" => "linear"
      })

    assert html_response(conn, 200) =~ "Time (UTC)"
  end

  test "GET /shellfeed relative feed", %{conn: conn} do
    user = add_user!()

    conn =
      get(conn, "/shellfeed", %{
        "user_id" => user.uuid,
        "view" => "relative"
      })

    assert html_response(conn, 200) =~ "table"
  end
end
