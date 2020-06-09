defmodule FishermanServer.QueryTest do
  use FishermanServer.DataCase
  import FishermanServer.TestFns

  alias FishermanServer.DB.Query

  test "shell records since dt" do
    %{uuid: user_id} = add_user!()

    [first | _rest] =
      records =
      for _ <- 1..3 do
        gen_shell_record()
        |> Map.put(:user_id, user_id)
        |> add_shell_record!()
      end

    start_dt = first.command_timestamp |> DateTime.add(-1, :second)

    found_records = Query.shell_records_since_dt(start_dt, user_id)

    assert length(records) == length(found_records)
    assert Enum.map(records, & &1.uuid) == Enum.map(found_records, & &1.uuid)
  end

  test "shell records since dt for wrong user_id" do
    %{uuid: user_id} = add_user!()

    [first | _rest] =
      _records =
      for _ <- 1..3 do
        add_shell_record!()
      end

    start_dt = first.command_timestamp |> DateTime.add(-1, :second)

    found_records = Query.shell_records_since_dt(start_dt, user_id)

    assert 0 == length(found_records)
  end

  test "shell records since dt for too late dt" do
    %{uuid: user_id} = add_user!()

    [_first | rest] =
      _records =
      for _ <- 1..3 do
        add_shell_record!()
      end

    [start_dt | _] =
      rest
      |> Enum.reverse()
      |> Enum.take(1)
      |> Enum.map(& &1.command_timestamp)
      |> Enum.map(&DateTime.add(&1, 10, :second))

    found_records = Query.shell_records_since_dt(start_dt, user_id)

    assert 0 == length(found_records)
  end
end
