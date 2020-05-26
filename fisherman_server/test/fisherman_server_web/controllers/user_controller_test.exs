defmodule FishermanServerWeb.UserControllerTest do
  use FishermanServerWeb.ConnCase

  test "POST /user", %{conn: conn} do
    conn =
      post(conn, "/user", %{
        "username" => "foo.bar",
        "email" => "foobarfoo@gmail.com",
        "machine_serial" => "xycj2oijdas",
        "first_name" => "henry",
        "last_name" => "warren"
      })

    expected_resp = %{
      "email" => "foobarfoo@gmail.com",
      "first_name" => "henry",
      "last_name" => "warren",
      "machine_serial" => "xycj2oijdas",
      "username" => "foo.bar"
    }

    actual_resp = json_response(conn, 200) |> Map.drop(["user_id"])
    assert expected_resp == actual_resp
  end
end
