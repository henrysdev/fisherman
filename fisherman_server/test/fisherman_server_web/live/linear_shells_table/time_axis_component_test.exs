defmodule FishermanServerWeb.TimeAxisComponentTest do
  use FishermanServerWeb.ConnCase
  import Phoenix.LiveViewTest
  alias FishermanServerWeb.Live.LinearShellsTable.TimeAxisComponent

  test "renders time axis column" do
    row_info = %{
      num_rows: 10,
      row_height: 3.5,
      pid_col_width: 20.0,
      time_incr: 1000,
      first_ts: 1_590_654_490_035,
      time_axis_width: 12
    }

    html_view = render_component(TimeAxisComponent, row_info: row_info)

    build_match_strings(row_info)
    |> Enum.each(&assert html_view =~ &1)
  end

  defp build_match_strings(row_info) do
    for x <- 1..row_info.num_rows do
      (row_info.first_ts + row_info.time_incr * x)
      |> DateTime.from_unix!(:millisecond)
      |> DateTime.to_string()
    end
  end
end
