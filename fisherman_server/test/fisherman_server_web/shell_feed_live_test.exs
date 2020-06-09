defmodule FishermanServerWeb.ShellFeedLiveTest do
  use FishermanServerWeb.ConnCase
  import FishermanServer.TestFns
  import Phoenix.LiveViewTest

  test "renders shell feed with records", %{conn: conn} do
    %{uuid: user_id} = add_user!()

    record =
      gen_shell_record()
      |> Map.put(:user_id, user_id)
      |> add_shell_record!()

    conn = get(conn, "/shellfeed", %{"user_id" => user_id})
    {:ok, view, _html} = live(conn)
    notif = %{"command_timestamp" => DateTime.utc_now(), "user_id" => user_id}
    send(view.pid, {:notify, notif})

    assert render(view) =~ record.command
    assert render(view) =~ record.pid
    assert view |> element(".shell-record") |> has_element?()
    assert view |> element(".time-axis") |> has_element?()
    assert view |> element(".time-tick") |> has_element?()
  end

  test "renders empty shell feed", %{conn: conn} do
    %{uuid: user_id} = add_user!()

    conn = get(conn, "/shellfeed", %{"user_id" => user_id})
    {:ok, view, _html} = live(conn)

    assert !(view |> element(".shell-record") |> has_element?())
    assert view |> element(".time-axis") |> has_element?()
    assert view |> element(".time-tick") |> has_element?()
  end
end
