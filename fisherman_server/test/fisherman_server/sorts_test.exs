defmodule FishermanServer.SortsTest do
  use FishermanServer.DataCase
  import FishermanServer.TestFns

  alias FishermanServer.{
    User,
    ShellRecord,
    Sorts
  }

  test "interval sort" do
    %User{uuid: user_id} = add_user!()

    shell_records =
      gen_shell_records_for_user(3, user_id) ++
        [
          gen_shell_record(
            user_id: user_id,
            uuid: Ecto.UUID.generate(),
            command_timestamp: DateTime.utc_now() |> DateTime.add(2, :second),
            error_timestamp: DateTime.utc_now() |> DateTime.add(4, :second)
          )
        ]

    assert [
             %{end: 3, start: 0},
             %{end: 4, start: 1},
             %{end: 5, start: 2},
             %{end: 7, start: 6}
           ] = Sorts.interval_sort(shell_records)
  end

  test "build table matrix" do
    %User{uuid: user_id} = add_user!()
    records = gen_shell_records_for_user(3, user_id)
    records = [gen_shell_record(user_id: user_id, pid: "def456") | records]

    [_ms1, _ms2] = [
      MapSet.new(0..6 |> Enum.to_list()),
      MapSet.new(3..7 |> Enum.to_list())
    ]

    assert pattern =
             {
               %{
                 "123" => %{
                   0 =>
                     {:start,
                      %{
                        fill_size: 4
                      }},
                   1 =>
                     {:start,
                      %{
                        fill_size: 4
                      }},
                   2 =>
                     {:start,
                      %{
                        fill_size: 4
                      }}
                 },
                 "def456" => %{3 => {:start, %{fill_size: 4, record_id: nil}}}
               },
               _lookup_map
             } = Sorts.build_table_matrix(records, ["123", "def456"])
  end
end
