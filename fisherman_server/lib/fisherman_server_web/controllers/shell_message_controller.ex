defmodule FishermanServerWeb.ShellMessageController do
  use FishermanServerWeb, :controller

  alias FishermanServer.{
    Repo,
    ShellRecord,
    Utils
  }

  def create(conn, params) do
    user_id = Map.fetch!(params, "user_id")

    Map.fetch!(params, "commands")
    |> Enum.each(&handle_shell_record(&1, user_id))

    json(conn, %{})
  end

  defp handle_shell_record(sh_record, user_id) do
    sh_record
    |> marshal(user_id)
    |> Repo.insert()
  end

  defp marshal(sh_record, user_id) do
    %ShellRecord{
      user_id: user_id,
      pid: get_in(sh_record, ["pid"]),
      command: get_in(sh_record, ["command", "line"]),
      command_timestamp:
        sh_record
        |> get_in(["command", "timestamp"])
        |> Utils.unix_millis_to_dt(),
      error: get_in(sh_record, ["stderr", "line"]),
      error_timestamp:
        sh_record
        |> get_in(["stderr", "timestamp"])
        |> Utils.unix_millis_to_dt()
    }
  end
end
