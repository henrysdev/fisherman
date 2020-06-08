ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(FishermanServer.Repo, :manual)

defmodule FishermanServer.TestFns do
  @moduledoc """
  This module provides handy functions for testing the FishermanServer project.
  """

  @default_user %FishermanServer.User{
    username: "foo.bar",
    email: "foobarfoo@gmail.com",
    machine_serial: "xycj2oijdas",
    first_name: "henry",
    last_name: "warren"
  }

  def new_user(user \\ @default_user) do
    FishermanServer.Repo.insert(user)
  end

  @default_shell_record %FishermanServer.ShellRecord{
    command: "cat somefile",
    command_timestamp: DateTime.utc_now(),
    error: "exit status 1",
    error_timestamp: DateTime.utc_now() |> DateTime.add(1, :second),
    pid: "123"
  }

  def new_shell_record(shell_record \\ @default_shell_record) do
    FishermanServer.Repo.insert(shell_record)
  end
end
