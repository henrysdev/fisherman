defmodule FishermanServer.NotificationPublisherTest do
  use FishermanServerWeb.ChannelCase

  alias FishermanServer.NotificationPublisher

  # TODO test publish and subscribe

  test "channel name" do
    user_id = "123abc"
    name = NotificationPublisher.channel_name(user_id)
    assert name == "notify_feed_refresh:123abc"
  end
end
