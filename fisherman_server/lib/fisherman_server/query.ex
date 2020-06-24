defmodule FishermanServer.Query do
  import Ecto.Query, warn: false

  alias FishermanServer.{
    Repo,
    ShellRecord
  }

  def shell_records_since_dt(datetime, user_id, include_errors \\ true) do
    query =
      ShellRecord
      |> where([sh], sh.error_timestamp >= datetime_add(^datetime, 0, "second"))
      |> where([sh], sh.user_id == ^user_id)
      |> (fn q ->
            case include_errors do
              false -> where(q, [sh], sh.error == "")
              _true -> q
            end
          end).()
      |> order_by([sh], asc: sh.command_timestamp)

    Repo.all(query)
  end
end
