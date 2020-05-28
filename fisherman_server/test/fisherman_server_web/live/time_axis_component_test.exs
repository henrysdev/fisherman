defmodule FishermanServerWeb.TimeAxisComponentTest do
  use FishermanServerWeb.ConnCase

  alias FishermanServerWeb.Live.ShellRecordsTable.TimeAxisComponent

  test "renders as expected" do
    row_info = %{
      num_rows: 10,
      row_height: 3.5,
      pid_col_width: 20.0,
      time_incr: 1000,
      first_ts: 1_590_654_490_035,
      time_axis_width: 12
    }

    expected_render = ["<div style=\"width: ", "rem\">\n\n  ", "\n\n</div>\n"]

    rendered = TimeAxisComponent.render(%{row_info: row_info})

    assert rendered.static == expected_render
  end
end
