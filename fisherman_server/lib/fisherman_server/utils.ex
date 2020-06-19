defmodule FishermanServer.Utils do
  @moduledoc """
  Utils provides module-agnostic convenience functions
  """
  @datetime_defaults [
    year: 0,
    month: 1,
    day: 1,
    zone_abbr: "EST",
    hour: 0,
    minute: 0,
    second: 0,
    microsecond: {0, 0},
    utc_offset: 0,
    std_offset: 0,
    time_zone: "Etc/UTC"
  ]
  @no_error_color "#a0cf93"
  @error_color "#f79292"

  @doc """
  Casts unix milliseconds to a microsecond-friendly datetime
  """
  def unix_millis_to_dt(millis) when is_integer(millis) do
    (millis * 1_000)
    |> DateTime.from_unix!(:microsecond)
  end

  def unix_millis_to_dt(_), do: nil

  @doc """
  Casts a postgres-json timestamp format to a datetime object
  """
  def pg_json_millis_to_dt(millis) do
    (millis <> "Z")
    |> Timex.Parse.DateTime.Parser.parse!("{ISO:Extended:Z}")
  end

  @doc """
  Encode the given datetime to be url safe. Use current utc time if not specified
  """
  def encode_url_datetime(datetime = %DateTime{} \\ DateTime.utc_now()) do
    datetime
    |> DateTime.to_unix(:millisecond)
    |> to_string()
  end

  @doc """
  Decode the datetime url to a datetime object
  """
  def decode_url_datetime(url_datetime) do
    {millis, _} = Integer.parse(url_datetime)
    DateTime.from_unix!(millis, :millisecond)
  end

  @doc """
  Build a datetime object from a map. Uses defaults for non-provided but required DateTime
  struct fields
  """
  def datetime_from_map(dt_map \\ %{}) do
    options =
      Enum.map(dt_map, fn {k, v} ->
        {String.to_existing_atom(k), parse_int!(v)}
      end)

    options =
      Keyword.merge(@datetime_defaults, options)
      |> Enum.into(%{})

    struct(DateTime, options)
  end

  @doc """
  Parse a string into an integer
  """
  def parse_int!(string) do
    {int, ""} = Integer.parse(string)
    int
  end

  def string_to_bool("true"), do: true
  def string_to_bool("false"), do: false

  @doc """
  Cast the map produces from a date select form field to a url safe datetime string
  """
  def datetime_form_to_url_datetime(dt_map \\ %{}) do
    options = Enum.map(dt_map, fn {k, v} -> {String.to_existing_atom(k), v} end)

    options =
      Keyword.merge(@datetime_defaults, options)
      |> Enum.into(%{})

    struct(DateTime, options)
  end

  @doc """
  Determines color of the shell record background on basis
  of if the command produced an error or not
  """
  def pick_color(%{error: error}) do
    if Enum.member?(["", nil], error) do
      @no_error_color
    else
      @error_color
    end
  end
end
