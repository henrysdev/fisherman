defmodule FishermanServerWeb.ShellRecordComponentTest do
  use FishermanServerWeb.ConnCase

  alias FishermanServerWeb.Live.ShellRecordsTable.ShellRecordComponent

  test "renders as expected" do
    record = %FishermanServer.ShellRecord{
      command: "ssh -N -L abc.com user.last@abc",
      command_timestamp: ~U[2020-05-28 08:28:12.035000Z],
      error: "zsh: command not found: asd",
      error_timestamp: ~U[2020-05-28 08:28:12.095000Z],
      inserted_at: ~N[2020-05-28 08:28:12],
      pid: "72508",
      updated_at: ~N[2020-05-28 08:28:12],
      user_id: "453cecfe-d768-47fa-8f0b-0e42b179c612",
      uuid: "6b88399c-361b-4fc5-bdbd-3c56e7c3d889"
    }

    expected_render = [
      "<div class=\"shell-record\"\nstyle=\"top: ",
      "rem;\n      height: ",
      "rem;\n      background-color: ",
      ";\"\nid=\"",
      "\">\n  <strong>",
      "</strong>\n</div>\n"
    ]

    rendered =
      ShellRecordComponent.render(%{
        y_offset: 7.0,
        height: 12.0,
        record: record
      })

    assert rendered.static == expected_render
  end

  test "picks color" do
    color_green = ShellRecordComponent.pick_color(%{error: ""})
    color_red = ShellRecordComponent.pick_color(%{error: "Error!"})

    assert color_green == "#a0cf93"
    assert color_red == "#f79292"
  end
end
