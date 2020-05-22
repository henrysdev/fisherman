defmodule FishermanServerWeb.ShellMessageController do
  use FishermanServerWeb, :controller

  alias FishermanServer.{
    Repo,
    ShellRecord,
    Utils
  }

  def new(conn, params) do
    params["commands"]
    |> Enum.each(&store_shell_message(&1))

    json(conn, %{})
  end

  defp store_shell_message(msg) do
    shell_record = shell_message_to_shell_record(msg)
    Repo.insert(shell_record)
  end

  defp shell_message_to_shell_record(msg) do
    # validate required params
    record =
      with {:ok, pid} <- Map.fetch(msg, "pid"),
           {:ok, cmd} <- Map.fetch(msg, "command"),
           {:ok, line} <- Map.fetch(cmd, "line"),
           {:ok, cmd_timestamp} <- Map.fetch(cmd, "timestamp") do
        %ShellRecord{
          pid: pid,
          command: line,
          # TODO put in utils
          command_timestamp: Utils.unix_millis_to_naive_dt(cmd_timestamp)
        }
      else
        err ->
          err
          raise "invalid message format"
      end

    # add extra params if present
    with {:ok, stderr} <- Map.fetch(msg, "stderr"),
         {:ok, line} <- Map.fetch(stderr, "line"),
         {:ok, stderr_timestamp} <- Map.fetch(stderr, "timestamp") do
      %ShellRecord{
        pid: record.pid,
        command: record.command,
        command_timestamp: record.command_timestamp,
        error: line,
        error_timestamp: Utils.unix_millis_to_naive_dt(stderr_timestamp)
      }
    else
      err ->
        err
        record
    end
  end
end
