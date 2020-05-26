defmodule FishermanServerWeb.ShellMessageController do
  use FishermanServerWeb, :controller

  alias FishermanServer.{
    Repo,
    ShellRecord,
    Utils,
    ClientTypes
  }

  def new(conn, params) do
    params["commands"]
    |> Enum.each(&handle_shell_record(&1))

    json(conn, %{})
  end

  defp handle_shell_record(sh_record) do
    sh_record
    |> marshal()
    |> Repo.insert()
  end

  defp marshal(sh_record) do
    %ShellRecord{
      pid: get_in(sh_record, ["pid"]),
      command: get_in(sh_record, ["command", "line"]),
      command_timestamp:
        sh_record
        |> get_in(["command", "timestamp"])
        |> Utils.unix_millis_to_naive_dt(),
      error: get_in(sh_record, ["stderr", "line"]),
      error_timestamp:
        sh_record
        |> get_in(["stderr", "timestamp"])
        |> Utils.unix_millis_to_naive_dt()
    }
  end
end
