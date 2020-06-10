defmodule FishermanServer.UtilsTest do
  use FishermanServer.DataCase
  import FishermanServer.TestFns

  alias FishermanServer.{
    User,
    Utils
  }

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
    %User{uuid: user_id} = add_user!()
    intervals = gen_shell_records_for_user(3, user_id)

    assert [
             %{end: 3, start: 0},
             %{end: 4, start: 1},
             %{end: 5, start: 2}
           ] = Utils.interval_sort(intervals)
  end

  test "build table matrix" do
    %User{uuid: user_id} = add_user!()
    records = gen_shell_records_for_user(3, user_id)
    records = [gen_shell_record(user_id: user_id, pid: "def456") | records]

    [_ms1, _ms2] = [
      MapSet.new([0, 1, 2, 3, 4, 5, 6]),
      MapSet.new([3, 4, 5, 6, 7])
    ]

    assert %{
             "123" => ms1,
             "def456" => ms2
           } = Utils.build_table_matrix(records)
  end
end
