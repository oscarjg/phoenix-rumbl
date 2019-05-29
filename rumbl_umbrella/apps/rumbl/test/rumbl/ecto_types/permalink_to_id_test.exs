defmodule Rumbl.EctoTypes.PermalinkToIdTest do
  use ExUnit.Case

  alias Rumbl.EctoTypes.PermalinkToId, as: P

  test "custom ecto type should work as expected" do
    assert P.cast(1) == {:ok, 1}
    assert P.cast("1") == {:ok, 1}
    assert P.cast("1-foo") == {:ok, 1}
    assert P.cast("foo") == :error
    assert P.cast("foo-1") == :error
  end
end