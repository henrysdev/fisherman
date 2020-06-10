ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(FishermanServer.Repo, :manual)

defmodule FishermanServer.TestFns do
  @moduledoc """
  This module provides handy functions for testing the FishermanServer project.
  """
  alias FishermanServer.{
    Repo,
    ShellRecord,
    User
  }

  @default_user_fields [
    username: "foo.bar",
    email: "foobarfoo@gmail.com",
    machine_serial: "xycj2oijdas",
    first_name: "henry",
    last_name: "warren"
  ]

  @default_shell_record_fields [
    command: "cat somefile",
    command_timestamp: DateTime.utc_now(),
    error: "exit status 1",
    error_timestamp: DateTime.utc_now() |> DateTime.add(1, :second),
    pid: "123"
  ]

  @doc """
  Generate a User from a provided keyword list. Any fields not
  specified in keyword list will be populated with default values
  """
  def gen_user(options \\ []) do
    defaults = @default_user_fields

    options =
      Keyword.merge(defaults, options)
      |> Enum.into(%{})

    struct(User, options)
  end

  def add_user!(user \\ gen_user()) do
    Repo.insert!(user)
  end

  def gen_shell_record(options \\ []) do
    defaults = @default_shell_record_fields

    options =
      Keyword.merge(defaults, options)
      |> Enum.into(%{})

    struct(ShellRecord, options)
  end

  def add_shell_record!(shell_record \\ gen_shell_record()) do
    Repo.insert!(shell_record)
  end
end
