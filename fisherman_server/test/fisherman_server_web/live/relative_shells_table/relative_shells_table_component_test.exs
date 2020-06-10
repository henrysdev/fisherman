defmodule FishermanServerWeb.RelativeShellsTableComponentTest do
  use FishermanServerWeb.ConnCase
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  import FishermanServer.TestFns

  test "disconnected and connected mount", %{conn: conn} do
    user = add_user!()

    conn =
      get(conn, "/shellfeed", %{
        "user_id" => user.uuid,
        "view" => "relative"
      })

    assert html_response(conn, 200) =~ "relative-shells-table"

    {:ok, _view, _html} = live(conn)
  end

  test "no session error on mount", %{conn: conn} do
    assert {:error, :nosession} = live(conn, "shellfeed")
  end
end
