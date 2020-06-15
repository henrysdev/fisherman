defmodule FishermanServer.Query do
  import Ecto.Query, warn: false

  alias FishermanServer.Repo

  def shell_records_since_dt(datetime, user_id) do
    query =
      from sh in FishermanServer.ShellRecord,
        where:
          sh.error_timestamp >=
            datetime_add(^datetime, 0, "second") and
            sh.user_id == ^user_id,
        order_by: [asc: :command_timestamp]

    Repo.all(query)
  end
end
