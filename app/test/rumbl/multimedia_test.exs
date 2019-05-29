defmodule Rumbl.MultimediaTest do
  use Rumbl.DataCase

  alias Rumbl.Multimedia
  alias Rumbl.Multimedia.Category
  alias Rumbl.Multimedia.Video
  alias Rumbl.Multimedia.Annotation

  describe "Categories" do
    test "list categories alphabetically" do
      for category_name <- ~w(Sports Drama Action Triathlon) do
        Multimedia.create_category(category_name)
      end

      alphabetical_categories = for %Category{name: name} <- Multimedia.list_alphabetical_categories() do
        name
      end

      assert ~w(Action Drama Sports Triathlon) == alphabetical_categories
    end
  end

  describe "Videos" do
    @valid_videos_attrs   %{title: "Test title", description: "Lorem ipsum", url: "https://foo.com"}
    @invalid_videos_attrs %{title: nil, description: nil, url: nil}

    test "list_videos/0 get all videos" do
      user1 = user_fixture(%{email: "user1@foo.com"})
      user2 = user_fixture(%{email: "user2@foo.com"})

      %Video{id: id_video_1} = video_fixture(user1)

      assert [%Video{id: ^id_video_1}] = Multimedia.list_videos()

      %Video{id: id_video_2} = video_fixture(user2)

      assert [%Video{id: ^id_video_1}, %Video{id: ^id_video_2}] = Multimedia.list_videos()
    end

    test "list_user_videos/1 get all videos by an user" do
      user1 = user_fixture(%{email: "user1@foo.com"})
      user2 = user_fixture(%{email: "user2@foo.com"})

      %Video{id: id_video_1} = video_fixture(user1)
      %Video{id: id_video_2} = video_fixture(user2)

      assert [%Video{id: ^id_video_1}] = Multimedia.list_user_videos(user1)
      assert [%Video{id: ^id_video_2}] = Multimedia.list_user_videos(user2)
    end

    test "get_video!/1 return the video with the given id" do
      owner = user_fixture(%{email: "user1@foo.com"})

      %Video{id: id} = video_fixture(owner)

      assert %Video{id: ^id} = Multimedia.get_video!(id)
    end

    test "create_video/2 create with valid data create a video" do
      owner = user_fixture(%{email: "user1@foo.com"})

      assert {:ok, %Video{} = video} = Multimedia.create_video(owner,  @valid_videos_attrs)

      assert video.title == "Test title"
      assert video.description == "Lorem ipsum"
      assert video.url == "https://foo.com"
    end

    test "create_video/2 create with invalid data return an error" do
      owner = user_fixture(%{email: "user1@foo.com"})

      assert {:error, %Ecto.Changeset{}} = Multimedia.create_video(owner,  @invalid_videos_attrs)
    end

    test "update_video/2 update video with valid data" do
      owner = user_fixture(%{email: "user1@foo.com"})
      video = video_fixture(owner, %{description: "Foo desc"})

      assert {:ok, %Video{} = updated_video} = Multimedia.update_video(
               video,
               %{title: "Updated title", url: "https//new.url"}
             )

      assert updated_video.title       == "Updated title"
      assert updated_video.url         == "https//new.url"
      assert updated_video.description == "Foo desc"

    end

    test "update_video/2 update video with invalid data return an error" do
      owner = user_fixture(%{email: "user1@foo.com"})
      video = video_fixture(owner, %{description: "Foo desc"})

      assert {:error, %Ecto.Changeset{} = changeset} = Multimedia.update_video(
               video,
               %{title: nil, url: "https//new.url"}
             )
    end

    test "delete_video/1 deletes the video" do
      owner = user_fixture(%{email: "user1@foo.com"})
      %Video{id: video_id} = video = video_fixture(owner, %{description: "Foo desc"})

      assert {:ok, %Video{} = video_deleted} = Multimedia.delete_video(video)
      assert video_deleted.id == video_id
      assert [] == Multimedia.list_videos()
    end

    test "change_video/2 return a changeset" do
      owner = user_fixture()
      video = video_fixture(owner)

      assert %Ecto.Changeset{} = Multimedia.change_video(owner, video)
    end
  end

  describe "Annotations" do
    test "create annotation with user and video" do
      user  = user_fixture()
      video = video_fixture(user)

      Multimedia.annotate_video(user, video.id, %{body: "foo message", at: 1234})

      assert [%Annotation{body: "foo message"}] = Repo.all(Annotation)
    end

    test "list annotation from video in correct order" do
      user  = user_fixture()
      video = video_fixture(user)

      annotation_fixture(user, video, %{at: 100})
      annotation_fixture(user, video, %{at: 400})
      annotation_fixture(user, video, %{at: 200})

      assert [%Annotation{at: 100}, %Annotation{at: 200}, %Annotation{at: 400}] = Multimedia.list_annotations(video)
    end
  end
end