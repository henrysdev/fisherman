defmodule FishermanServerWeb.ShellRecordsTableComponentTest do
  use FishermanServerWeb.ConnCase
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  test "disconnected and connected mount", %{conn: conn} do
    conn =
      get(conn, "/cmdfeed", %{
        "user_id" => "abc123",
        "from_ts" => 1_590_655_333_769 |> DateTime.from_unix!(:millisecond)
      })

    assert html_response(conn, 200) =~ "Time (UTC)"

    {:ok, _view, _html} = live(conn)
  end

  test "no session error on mount", %{conn: conn} do
    assert {:error, :nosession} = live(conn, "cmdfeed")
  end
end
