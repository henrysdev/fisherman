defmodule FishermanServerWeb.ShellFeedLiveTest do
  use FishermanServerWeb.ConnCase
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias FishermanServer.TestFns

  test "renders expected feed", %{conn: conn} do
    {:ok, user} = TestFns.new_user()

    # conn = get(conn, "/cmdfeed")
    # assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end

  test "GET /cmdfeed with valid user query param", %{conn: conn} do
    {:ok, user} = TestFns.new_user()

    conn =
      get(conn, "/cmdfeed", %{
        "user_id" => user.uuid
      })

    assert html_response(conn, 200) =~ "Time (UTC)"
  end
end
