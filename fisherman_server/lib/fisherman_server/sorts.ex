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
  6. Build a lookup by order index map to return with the list
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
          %{ts: DateTime.to_unix(sm, :millisecond), id: id, bound: 0},
          %{ts: DateTime.to_unix(em, :millisecond), id: id, bound: 1}
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

  # Bucket the bound into its appropriate container
  defp split_bounds({%{bound: 0}, _rel_order} = boundary, acc) do
    Map.update!(acc, :starts, &[boundary | &1])
  end

  defp split_bounds({%{bound: 1, id: id}, rel_order} = _boundary, %{ends: ends} = acc) do
    Map.put(acc, :ends, Map.put(ends, id, rel_order))
  end

  @doc """
  Build a 2D map of content by row for UI table
  """
  def build_table_matrix(records, pids) do
    # Build lookup of record uuid -> record
    record_lookup = Enum.reduce(records, %{}, &Map.put(&2, &1.uuid, &1))

    # Maintain a set of occupied bounds for each pid
    pids_map =
      pids
      |> Enum.reduce(%{}, &Map.put(&2, &1, %{}))

    # Populate occupied bounds for each pid
    sorted_intervals = records

    matrix =
      records
      |> interval_sort()
      |> Enum.reduce(pids_map, &add_cell_info(&1, &2, record_lookup))

    {matrix, record_lookup}
  end

  defp add_cell_info(
         %{id: id, start: start_idx, end: end_idx},
         pids_map,
         record_lookup
       ) do
    # Fetch whole shell record object from lookup map
    %{
      pid: pid,
      uuid: record_id
    } = Map.get(record_lookup, id)

    # Place in map with identifier to denote the start of a block
    # as well as how many spaces it will take up
    fill_size = abs(end_idx - start_idx)

    cell_info = %{
      fill_size: fill_size,
      record_id: record_id
    }

    # rel_order_idx maps to cell info
    idx_map_for_pid = Map.get(pids_map, pid, %{})
    pid_map = Map.put(idx_map_for_pid, start_idx, {:start, cell_info})

    # Generate :fill records for cells that should be skipped akin
    # to how <td> cells are skipped by rowspan/colspan
    pid_map =
      if fill_size > 1 do
        (start_idx + 1)..(end_idx - 1)
        |> Enum.reduce(pid_map, &Map.put(&2, &1, :fill))
      else
        pid_map
      end

    Map.put(pids_map, pid, pid_map)
  end

  # Builds a mapping from rel_order_idx -> record_id for interval bounds
  # NOTE Not used currently
  defp build_order_idx_lookup(intervals) do
    lookup_by_order_idx =
      Enum.reduce(intervals, %{}, fn item, acc ->
        acc
        |> Map.put(item.start, item.id)
        |> Map.put(item.end, item.id)
      end)
  end
end
