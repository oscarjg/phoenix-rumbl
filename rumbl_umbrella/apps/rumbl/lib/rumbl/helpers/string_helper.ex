defmodule Rumbl.Helpers.StringHelper do
  def slugify(str) do
    str
    |> String.downcase()
    |> String.trim()
    |> String.replace(~r/[^\w|\s]+/u, "")
    |> String.replace(~r/[^\w-]+/u, "-")
  end
end