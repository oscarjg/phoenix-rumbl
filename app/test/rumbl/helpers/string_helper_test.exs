defmodule Rumbl.Helpers.StringHelperTest do
  use ExUnit.Case

  alias Rumbl.Helpers.StringHelper

  test "slugs should create as expected" do
    assert StringHelper.slugify("Test title") == "test-title"
    assert StringHelper.slugify("Test title 2") == "test-title-2"
    assert StringHelper.slugify("Test title 2  ") == "test-title-2"
    assert StringHelper.slugify("Test title 2.") == "test-title-2"
  end
end