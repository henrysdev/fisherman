defmodule FishermanServer.Utils do
  def unix_millis_to_naive_dt(millis) do
    millis
    |> DateTime.from_unix!(:millisecond)
    |> DateTime.to_naive()
    |> NaiveDateTime.truncate(:second)
  end
end
