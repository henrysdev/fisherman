defmodule FishermanServer.UtilsTest do
  use ExUnit.Case

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

  test "interval sort" do
    intervals = [
      {"abc123", {0, 3}},
      {"def123", {1, 4}},
      {"ghi123", {2, 3.1}},
      {"jkl123", {3.5, 7}},
      {"mno123", {6, 7.5}},
      {"pqr123", {9, 10}}
    ]

    expected = [
      %{end: 11, id: "pqr123", start: 10},
      %{end: 9, id: "mno123", start: 7},
      %{end: 8, id: "jkl123", start: 5},
      %{end: 4, id: "ghi123", start: 2},
      %{end: 6, id: "def123", start: 1},
      %{end: 3, id: "abc123", start: 0}
    ]

    assert expected == Utils.interval_sort(intervals)
  end
end
