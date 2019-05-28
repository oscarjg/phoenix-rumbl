defmodule RumblWeb.WatchViewTest do
  use RumblWeb.ConnCase, async: true

  alias Rumbl.Multimedia.Video
  alias RumblWeb.WatchView

  test "player_id should return a valid youtube video id" do
    videos = [
      %Video{url: "http://youtu.be/0zM3nApSvMg"},
      %Video{url: "http://www.youtube.com/watch?v=0zM3nApSvMg&feature=feedrec_grec_index"},
      %Video{url: "http://www.youtube.com/user/IngridMichaelsonVEVO#p/a/u/1/0zM3nApSvMg"},
      %Video{url: "http://www.youtube.com/v/0zM3nApSvMg?fs=1&amp;hl=en_US&amp;rel=0"},
      %Video{url: "http://www.youtube.com/watch?v=0zM3nApSvMg#t=0m10s"},
      %Video{url: "http://www.youtube.com/embed/0zM3nApSvMg?rel=0"},
      %Video{url: "http://www.youtube.com/watch?v=0zM3nApSvMg"},
    ]

    Enum.each(videos, fn video ->
      assert "0zM3nApSvMg" == WatchView.player_id(video)
    end)
  end
end