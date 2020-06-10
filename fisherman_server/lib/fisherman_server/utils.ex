defmodule FishermanServer.Utils do
  @moduledoc """
  Utils provides module-agnostic convenience functions
  """

  def unix_millis_to_dt(millis) when is_integer(millis) do
    (millis * 1_000)
    |> DateTime.from_unix!(:microsecond)
  end

  def unix_millis_to_dt(_), do: nil

  def pg_json_millis_to_dt(millis) do
    (millis <> "Z")
    |> Timex.Parse.DateTime.Parser.parse!("{ISO:Extended:Z}")
  end

  @doc """
  Sort shell records by relative time interval. This is accomplished
  by the following process:

  1. Separate each shell record into two bounds (start and end)
  2. Sort all bounds by timestamp and record their sorted order
  3. Split up the processed bounds into two data structures:
    - A list of start-boundaries
    - A map consisting of command_id -> end-boundary order lookups
  4. Iterate over each start-boundary and lookup its corresponding
     end boundary by shared id.
  5. Merge each corresponding boundary into a structure %{id, start, end}
    - id = string identifier for shell record
    - start = integer denoting start boundary's relative order to
      other boundaries.
    - end = integer denoting end boundary's relative order to
      other boundaries.
  """
  def interval_sort(intervals) do
    %{
      starts: starts,
      ends: ends
    } =
      intervals
      |> Enum.reduce([], fn {id, {sm, em}}, acc ->
        [
          %{val: sm, id: id, bound: 0},
          %{val: em, id: id, bound: 1}
          | acc
        ]
      end)
      |> Enum.sort(&(&1.val <= &2.val))
      |> Enum.with_index()
      |> Enum.reduce(%{starts: [], ends: %{}}, &split_bounds(&1, &2))

    results =
      starts
      |> Enum.map(fn {%{id: id}, idx} ->
        %{id: id, start: idx, end: Map.get(ends, id)}
      end)

    IO.inspect({:RESULTS, results})
    results
  end

  defp split_bounds({%{bound: 0}, _rel_order} = boundary, acc) do
    Map.update!(acc, :starts, &[boundary | &1])
  end

  defp split_bounds({%{bound: 1, id: id}, rel_order} = boundary, acc) do
    %{starts: acc.starts, ends: Map.put(acc.ends, id, rel_order)}
  end
end
