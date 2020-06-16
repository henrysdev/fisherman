defmodule FishermanServerWeb.Live.RelativeShellsTableTest do
  use FishermanServerWeb.ConnCase
  import FishermanServer.TestFns
  import Phoenix.LiveViewTest

  test "renders relative shell feed with records and click actions", %{conn: conn} do
    %{uuid: user_id} = add_user!()

    records = [
      gen_shell_record()
      |> Map.put(:user_id, user_id)
      |> Map.put(:pid, "123")
      |> add_shell_record!(),
      gen_shell_record()
      |> Map.put(:user_id, user_id)
      |> Map.put(:pid, "456")
      |> add_shell_record!()
    ]

    conn =
      get(conn, "/shellfeed", %{
        "user_id" => user_id,
        "view" => "relative"
      })

    {:ok, view, _html} = live(conn)
    notif = %{"command_timestamp" => DateTime.utc_now(), "user_id" => user_id}
    send(view.pid, {:notify, notif})

    view
    |> table_assertions()
    |> record_assertions(records)
    |> inspector_assertions(records)
    |> table_menu_assertions()
  end

  test "renders empty relative shell feed", %{conn: conn} do
    %{uuid: user_id} = add_user!()

    conn =
      get(conn, "/shellfeed", %{
        "user_id" => user_id,
        "view" => "relative"
      })

    {:ok, view, _html} = live(conn)

    table_assertions(view)
  end

  defp table_assertions(view) do
    assert view |> element(".grid") |> has_element?()
    view
  end

  defp record_assertions(view, records) do
    assert view |> element(".grid-cell") |> has_element?()
    rendered_view = render(view)

    Enum.each(records, fn record ->
      assert rendered_view =~ record.command
      assert rendered_view =~ "PID #{record.pid}"
    end)

    view
  end

  defp inspector_assertions(view, records_to_inspect) do
    Enum.each(records_to_inspect, fn record ->
      rendered_view =
        render_click(
          view,
          :open_slideout,
          %{"record_id" => record.uuid}
        )

      assert rendered_view =~ "Command: "
      assert rendered_view =~ record.command
      assert rendered_view =~ "Error: "
      assert rendered_view =~ record.error
      assert rendered_view =~ "UUID: "
      assert rendered_view =~ record.uuid
      assert rendered_view =~ "Execution Time"
    end)

    view
  end

  defp table_menu_assertions(view) do
    assert view |> element(".table-menu") |> has_element?()
    assert view |> element(".table-menu-header") |> has_element?()
    assert view |> element(".table-menu-content") |> has_element?()
    rendered_view = render(view)

    assert rendered_view =~ "ZSH Shell History"
    view
  end
end
