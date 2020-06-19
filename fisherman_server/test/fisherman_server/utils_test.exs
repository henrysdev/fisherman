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

  test "datetime from sparse fields" do
    expected_datetime = %DateTime{
      year: 2000,
      month: 2,
      day: 29,
      zone_abbr: "EST",
      hour: 23,
      minute: 0,
      second: 0,
      microsecond: {0, 0},
      utc_offset: 0,
      std_offset: 0,
      time_zone: "Etc/UTC"
    }

    dt_map = %{
      "year" => "2000",
      "month" => "2",
      "day" => "29",
      "hour" => "23",
      "minute" => "0"
    }

    dt = Utils.datetime_from_map(dt_map)

    assert dt == expected_datetime
  end
end
