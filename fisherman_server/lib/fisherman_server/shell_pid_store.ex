defmodule FishermanServer.ShellPIDStore do
  use Agent

  @doc """
  Starts a new bucket.
  """
  def start_link(_opts) do
    Agent.start_link(fn ->
      %{
        pidset: MapSet.new(),
        ordered_pids: [],
        hidden_pidset: MapSet.new()
      }
    end)
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def update_pids(pidstore_pid, pids) do
    state = Agent.get(pidstore_pid, & &1)

    # Find new pids
    new_pids =
      pids
      |> Enum.reject(&MapSet.member?(state.pidset, &1))
      |> Enum.reject(&MapSet.member?(state.hidden_pidset, &1))
      |> Enum.uniq()

    # Update pidset and ordered pids
    new_pidset =
      new_pids
      |> Enum.reduce(state.pidset, &MapSet.put(&2, &1))

    new_ordered_pids = state.ordered_pids ++ new_pids

    Agent.update(pidstore_pid, fn _ ->
      %{
        pidset: new_pidset,
        ordered_pids: new_ordered_pids,
        hidden_pidset: state.hidden_pidset
      }
    end)
  end

  @doc """
  Updates pids and returns new pids list
  """
  def update_and_get_pids(pidstore_pid, pids) do
    update_pids(pidstore_pid, pids)
    Agent.get(pidstore_pid, & &1.ordered_pids)
  end

  @doc """
  Get ordered pid list
  """
  def get_ordered_pids(pidstore_pid) do
    Agent.get(pidstore_pid, & &1.ordered_pids)
  end

  @doc """
  Get set of pids in pid list
  """
  def get_pidset(pidstore_pid) do
    Agent.get(pidstore_pid, & &1.pidset)
  end

  @doc """
  Removes the specified pid from pidlist and adds to hidden pids
  """
  def hide_pid(pidstore_pid, pid) do
    state = Agent.get(pidstore_pid, & &1)

    # Add to hidden pidset
    new_hidden_pidset =
      state
      |> get_in([:hidden_pidset])
      |> MapSet.put(pid)

    # Remove from active pidset
    new_pidset = MapSet.delete(state.pidset, pid)

    # Remove from ordered pids
    new_ordered_pids = Enum.reject(state.ordered_pids, &(&1 == pid))

    # Update entire agent state and return active pids
    Agent.update(pidstore_pid, fn _ ->
      %{
        hidden_pidset: new_hidden_pidset,
        pidset: new_pidset,
        ordered_pids: new_ordered_pids
      }
    end)
  end

  @doc """
  Adds the specified pid back to the pidlist and remove from hidden pids
  """
  def unhide_pid(pidstore_pid, pid) do
    state = Agent.get(pidstore_pid, & &1)

    # Delete pid from hidden pidset
    new_hidden_pidset =
      state
      |> get_in([:hidden_pidset])
      |> MapSet.delete(pid)

    # Update state with new hidden pidset
    Agent.update(pidstore_pid, fn _ ->
      %{
        hidden_pidset: new_hidden_pidset,
        pidset: state.pidset,
        ordered_pids: state.ordered_pids
      }
    end)

    update_pids(pidstore_pid, [pid])
  end
end
