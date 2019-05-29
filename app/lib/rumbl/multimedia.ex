defmodule Rumbl.Multimedia do
  @moduledoc """
  The Multimedia context.
  """

  import Ecto.Query, warn: false
  alias Rumbl.Repo

  alias Rumbl.Multimedia.Video
  alias Rumbl.Multimedia.Category
  alias Rumbl.Accounts.User

  @doc """
  Returns the list of videos.

  ## Examples

      iex> list_videos()
      [%Video{}, ...]

  """
  def list_videos do
    Repo.all(Video)
  end

  @doc """
  Returns the list of videos by specific user.
  """
  def list_user_videos(%User{} = user) do
    Video
    |> user_videos_query(user)
    |> Repo.all()
    #|> preload_user()
  end

  @doc """
  Returns a video scoped by user
  """
  def get_user_video!(%User{} = user, video_id) do
    from(v in Video, where: v.id == ^video_id)
    |> user_videos_query(user)
    |> Repo.one!()
    |> preload_user()
  end

  @doc """
  Gets a single video.

  Raises `Ecto.NoResultsError` if the Video does not exist.

  ## Examples

      iex> get_video!(123)
      %Video{}

      iex> get_video!(456)
      ** (Ecto.NoResultsError)

  """
  def get_video!(id) do
    Repo.get!(Video, id)
    |> preload_user()
  end

  @doc """
  Creates a video.

  ## Examples

      iex> create_video(%{field: value})
      {:ok, %Video{}}

      iex> create_video(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_video(%User{} = user, attrs \\ %{}) do
    %Video{}
    |> Video.changeset(attrs)
    |> put_user(user)
    |> Repo.insert()
  end

  @doc """
  Updates a video.

  ## Examples

      iex> update_video(video, %{field: new_value})
      {:ok, %Video{}}

      iex> update_video(video, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_video(%Video{} = video, attrs) do
    video
    |> Video.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Video.

  ## Examples

      iex> delete_video(video)
      {:ok, %Video{}}

      iex> delete_video(video)
      {:error, %Ecto.Changeset{}}

  """
  def delete_video(%Video{} = video) do
    Repo.delete(video)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking video changes.

  ## Examples

      iex> change_video(video)
      %Ecto.Changeset{source: %Video{}}

  """
  def change_video(%User{} = user, %Video{} = video) do
    video
    |> Video.changeset(%{})
    |> put_user(user)
  end

  defp user_videos_query(video, %User{id: user_id}) do
    from(v in video, where: v.user_id == ^user_id)
  end

  defp put_user(changeset, %User{} = user) do
    changeset
    |> Ecto.Changeset.put_assoc(:user, user)
  end

  defp preload_user(video_or_videos) do
    Repo.preload(video_or_videos, :user)
  end

  @doc """
  Creates a category

  Method to be used by seeds only
  """
  def create_category(name) do
    Repo.get_by(Category, name: name) || Repo.insert!(%Category{ name: name })
  end

  @doc """
  Fetch all categories ordered by name
  """
  def list_alphabetical_categories() do
    Category
    |> Category.alphabetical()
    |> Repo.all()
  end

  alias Rumbl.Multimedia.Annotation

  @doc """
  Add video annotation
  """
  def annotate_video(%User{} = user, video_id, attr) do
    %Annotation{video_id: video_id}
    |> Annotation.changeset(attr)
    |> put_user(user)
    |> Repo.insert()
  end

  def list_annotations(%Video{} = video, since_id \\ 0) do
    query = from a in Ecto.assoc(video, :annotations),
         order_by: [asc: a.at, asc: a.id],
         where: a.id > ^since_id,
         limit: 500,
         preload: [:user]

    Repo.all(query)
  end
end
