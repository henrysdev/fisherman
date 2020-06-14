defmodule FishermanServerWeb.Live.RelativeShellsTableTest do
  use FishermanServerWeb.ConnCase
  import FishermanServer.TestFns
  import Phoenix.LiveViewTest

  test "renders relative shell feed with records", %{conn: conn} do
    %{uuid: user_id} = add_user!()

    record =
      gen_shell_record()
      |> Map.put(:user_id, user_id)
      |> add_shell_record!()

    conn =
      get(conn, "/shellfeed", %{
        "user_id" => user_id,
        "view" => "relative"
      })

    {:ok, view, _html} = live(conn)
    notif = %{"command_timestamp" => DateTime.utc_now(), "user_id" => user_id}
    send(view.pid, {:notify, notif})

    assert render(view) =~ record.command
    assert render(view) =~ record.pid
    default_assertions(view)
  end

  test "renders empty relative shell feed", %{conn: conn} do
    %{uuid: user_id} = add_user!()

    conn =
      get(conn, "/shellfeed", %{
        "user_id" => user_id,
        "view" => "relative"
      })

    {:ok, view, _html} = live(conn)

    default_assertions(view)
  end

  defp default_assertions(view) do
    assert view |> element(".grid") |> has_element?()
  end
end
