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
    assert ShellPIDStore.get_pids(sh_pid_store) == orig_pids

    new_pids = ["890", "191"]
    messy_pids = new_pids ++ Enum.shuffle(orig_pids)
    assert ShellPIDStore.update_pids(sh_pid_store, messy_pids) == :ok
    assert ShellPIDStore.get_pids(sh_pid_store) == orig_pids ++ new_pids

    assert ShellPIDStore.update_and_get_pids(sh_pid_store, messy_pids) ==
             orig_pids ++ new_pids
  end
end
