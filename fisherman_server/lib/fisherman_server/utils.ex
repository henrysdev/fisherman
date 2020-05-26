defmodule FishermanServer.Utils do
  def unix_millis_to_naive_dt(millis) when is_integer(millis) do
    millis
    |> DateTime.from_unix!(:millisecond)
    |> DateTime.to_naive()
    |> NaiveDateTime.truncate(:second)
  end

  def unix_millis_to_naive_dt(_), do: nil
end
