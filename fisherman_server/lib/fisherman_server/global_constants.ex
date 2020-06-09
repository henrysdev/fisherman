defmodule FishermanServer.GlobalConstants do
  use Constants

  # PubSub
  define(channel_name, "notify_feed_refresh")
  define(pg_channel, "shell_record_inserts")
end
