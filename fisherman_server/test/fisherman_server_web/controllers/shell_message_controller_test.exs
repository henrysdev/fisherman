defmodule FishermanServerWeb.ShellMessageControllerTest do
  use FishermanServerWeb.ConnCase
  import FishermanServer.TestFns

  test "POST /api/shellmsg", %{conn: conn} do
    %FishermanServer.User{uuid: user_id} = add_user!()

    conn =
      post(conn, "/api/shellmsg", %{
        "user_id" => user_id,
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

  test "POST /api/shellmsg should raise error due to no pid", %{conn: conn} do
    %FishermanServer.User{uuid: user_id} = add_user!()

    resp =
      try do
        post(conn, "/api/shellmsg", %{
          "user_id" => user_id,
          "commands" => [
            %{
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

        false
      rescue
        Postgrex.Error -> true
      end

    assert resp == true
  end

  test "POST /api/shellmsg should raise error due to no user_id", %{conn: conn} do
    resp =
      try do
        post(conn, "/api/shellmsg", %{
          "commands" => [
            %{
              "pid" => "123",
              "stderr" => %{
                "line" => "ValueError(`asdf`)",
                "timestamp" => 1_590_121_160_862
              }
            }
          ]
        })

        false
      rescue
        KeyError -> true
      end

    assert resp == true
  end
end
