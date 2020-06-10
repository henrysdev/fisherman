defmodule FishermanServer.Sorts do
  @moduledoc """
  Provides handy algorithm helpers
  """

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
      |> Enum.reduce([], fn %FishermanServer.ShellRecord{
                              uuid: id,
                              command_timestamp: sm,
                              error_timestamp: em
                            },
                            acc ->
        [
          %{ts: sm |> DateTime.to_unix(:millisecond), id: id, bound: 0},
          %{ts: em |> DateTime.to_unix(:millisecond), id: id, bound: 1}
          | acc
        ]
      end)
      |> Enum.sort(&(&1.ts <= &2.ts))
      |> Enum.with_index()
      |> Enum.reduce(%{starts: [], ends: %{}}, &split_bounds(&1, &2))

    results =
      starts
      |> Enum.reverse()
      |> Enum.map(fn {%{id: id}, idx} ->
        %{id: id, start: idx, end: Map.get(ends, id)}
      end)

    results
  end

  defp split_bounds({%{bound: 0}, _rel_order} = boundary, acc) do
    Map.update!(acc, :starts, &[boundary | &1])
  end

  defp split_bounds({%{bound: 1, id: id}, rel_order} = _boundary, acc) do
    %{starts: acc.starts, ends: Map.put(acc.ends, id, rel_order)}
  end

  @doc """
  Build a 2D map of content by row for UI table
  """
  def build_table_matrix(records, pids) do
    # Build lookup of record uuid -> record
    record_lookup = Enum.reduce(records, %{}, &Map.put(&2, &1.uuid, &1))

    # Maintain a set of occupied bounds for each pid
    pid_map =
      pids
      |> Enum.reduce(%{}, &Map.put(&2, &1, %{}))

    # Populate occupied bounds for each pid
    matrix =
      records
      |> interval_sort()
      |> Enum.reduce(pid_map, fn r, acc ->
        # Fetch whole shell record object from lookup map
        found_record = Map.get(record_lookup, r.id)

        # Pull out and update map
        cell_map = Map.get(acc, found_record.pid)

        # Place in map with identifier to denote the start of a block
        # as well as how many spaces it will take up
        fill_size = abs(r.end - r.start)

        record_ref_obj = %{
          fill_size: fill_size,
          record_id: found_record.uuid
        }

        # rel_order_idx maps to cell info
        new_cell_set = Map.put(cell_map, r.start, {:start, record_ref_obj})

        # TODO improve this approach... will not scale to large datasets
        new_cell_set =
          if fill_size > 1 do
            (r.start + 1)..(r.end - 1)
            |> Enum.reduce(new_cell_set, &Map.put(&2, &1, :fill))
          else
            new_cell_set
          end

        # Put back into map
        Map.put(acc, found_record.pid, new_cell_set)
      end)

    {matrix, record_lookup}
  end
end
