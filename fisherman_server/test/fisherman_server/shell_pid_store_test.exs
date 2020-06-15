defmodule FishermanServer.ShellPIDStoreTest do
  use ExUnit.Case, async: true

  alias FishermanServer.ShellPIDStore

  setup do
    {:ok, sh_pid_store} = ShellPIDStore.start_link([])
    %{sh_pid_store: sh_pid_store}
  end

  test "stores and retrieves pids", %{sh_pid_store: sh_pid_store} do
    orig_pids = ["123", "456", "789"]
    assert ShellPIDStore.update_pids(sh_pid_store, orig_pids) == :ok
    assert Agent.get(sh_pid_store, & &1.ordered_pids) == orig_pids

    new_pids = ["890", "191"]
    messy_pids = new_pids ++ Enum.shuffle(orig_pids)
    assert ShellPIDStore.update_pids(sh_pid_store, messy_pids) == :ok
    assert Agent.get(sh_pid_store, & &1.ordered_pids) == orig_pids ++ new_pids

    assert ShellPIDStore.update_and_get_pids(sh_pid_store, messy_pids) ==
             orig_pids ++ new_pids
  end

  test "hides pid on request", %{sh_pid_store: sh_pid_store} do
    orig_pids = ["123", "456", "789"]
    assert ShellPIDStore.update_pids(sh_pid_store, orig_pids) == :ok
    assert Agent.get(sh_pid_store, & &1.ordered_pids) == orig_pids

    assert ShellPIDStore.hide_pid(sh_pid_store, "123") == :ok
    assert Agent.get(sh_pid_store, & &1.ordered_pids) == ["456", "789"]
    assert Agent.get(sh_pid_store, & &1.hidden_pidset) |> MapSet.member?("123")

    assert ShellPIDStore.unhide_pid(sh_pid_store, "123") == :ok
    assert Agent.get(sh_pid_store, & &1.ordered_pids) == ["456", "789", "123"]
  end
end
