defmodule RumblWeb.VideoView do
  use RumblWeb, :view

  def category_select_options(categories) do
    Enum.map(categories, fn category ->
      {category.name, category.id}
    end)
  end
end
