defmodule FishermanServerWeb.ShellFeedLiveTest do
  use FishermanServerWeb.ConnCase
  import FishermanServerWeb.ChannelCase

  alias FishermanServer.TestFns

  test "renders expected feed", %{conn: conn} do
    conn = get(conn, "/shellfeed")
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end

  test "GET /shellfeed with valid user query param", %{conn: conn} do
    user = TestFns.add_user!()

    conn =
      get(conn, "/shellfeed", %{
        "user_id" => user.uuid
      })

    # TODO simulate refresh and assert html contents

    assert html_response(conn, 200) =~ "Time (UTC)"
  end
end
