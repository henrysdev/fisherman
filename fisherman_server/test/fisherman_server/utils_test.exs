defmodule FishermanServer.UtilsTest do
  use FishermanServer.DataCase

  alias FishermanServer.Utils

  test "unix millis to dt " do
    dt = Utils.unix_millis_to_dt(1_591_317_759_447)
    assert dt == ~U[2020-06-05 00:42:39.447000Z]
  end

  test "unix millis to dt when millis is nil" do
    dt = Utils.unix_millis_to_dt(nil)
    assert dt == nil
  end

  test "pg json millis to dt" do
    dt = Utils.pg_json_millis_to_dt("2020-06-08T21:11:36.919")
    assert dt == ~U[2020-06-08 21:11:36.919Z]
  end
end
