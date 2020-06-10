defmodule FishermanServer.ShellPIDStore do
  use Agent

  @doc """
  Starts a new bucket.
  """
  def start_link(_opts) do
    Agent.start_link(fn ->
      %{
        pidset: MapSet.new(),
        ordered_pids: []
      }
    end)
  end

  @doc """
  Returns the current ordered list of pids
  """
  def get_pids(pidstore_pid) do
    Agent.get(pidstore_pid, & &1.ordered_pids)
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def update_pids(pidstore_pid, pids) do
    %{
      pidset: pidset,
      ordered_pids: ordered_pids
    } = Agent.get(pidstore_pid, & &1)

    # Find new pids
    new_pids =
      pids
      |> Enum.reject(&MapSet.member?(pidset, &1))
      |> Enum.uniq()

    # Update pidset
    new_pidset =
      new_pids
      |> Enum.reduce(pidset, &MapSet.put(&2, &1))

    Agent.update(pidstore_pid, fn _ ->
      %{
        pidset: new_pidset,
        ordered_pids: ordered_pids ++ new_pids
      }
    end)
  end

  def update_and_get_pids(pidstore_pid, pids) do
    update_pids(pidstore_pid, pids)
    get_pids(pidstore_pid)
  end
end
