defmodule FishermanServer.UtilsTest do
  use ExUnit.Case

  test "unix millis to dt " do
    dt = FishermanServer.Utils.unix_millis_to_dt(1_591_317_759_447)
    assert dt == ~U[2020-06-05 00:42:39.447000Z]
  end
end
