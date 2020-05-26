defmodule FishermanServerWeb.ShellMessageControllerTest do
  use FishermanServerWeb.ConnCase

  test "POST /shellmsg", %{conn: conn} do
    conn =
      post(conn, "/shellmsg", %{
        "commands" => [
          %{
            "pid" => "123",
            "command" => %{
              "line" => "python3 -c 'raise ValueError(`asdf`)'",
              "timestamp" => 1_590_121_160_762
            },
            "stderr" => %{
              "line" => "ValueError(`asdf`)",
              "timestamp" => 1_590_121_160_862
            }
          }
        ]
      })

    assert json_response(conn, 200) == %{}
  end

  test "POST /shellmsg should raise error due to no pid", %{conn: conn} do
    resp =
      try do
        post(conn, "/shellmsg", %{
          "commands" => [
            %{
              "stderr" => %{
                "line" => "ValueError(`asdf`)",
                "timestamp" => 1_590_121_160_862
              }
            }
          ]
        })

        false
      rescue
        Postgrex.Error -> true
      end

    assert resp == true
  end
end
