defmodule InfoSysTest do
  use ExUnit.Case
  alias InfoSys.Result

  defmodule TestBackend do
    @behaviour InfoSys.Backend
    @module_name __MODULE__

    def start_link(query, ref, owner, limit) do
      Task.start_link(@module_name, :fetch, [query, ref, owner, limit])
    end

    @impl true
    def name(), do: "Wolfram"

    @impl true
    def compute("result", _opts) do
      [%Result{backend: @module_name, text: "result"}]
    end

    @impl true
    def compute("none", _opts) do
      []
    end

    @impl true
    def compute("timeout", _opts) do
      :timer.sleep(:infinity)
    end

    @impl true
    def compute("boom", _opts) do
      raise "boom!"
    end
  end

  test "compute/2 with backend results" do
    assert [%Result{backend: TestBackend, text: "result"}] = InfoSys.compute("result", backends: [TestBackend])
  end

  test "compute/2 with no backend results" do
    assert [] = InfoSys.compute("none", backends: [TestBackend])
  end

  test "compute/2 with timeout returns no results" do
    assert InfoSys.compute("timeout", backends: [TestBackend], timeout: 10) == []
  end

  @tag :capture_log
  test "compute/2 discards backend errors" do
    assert InfoSys.compute("boom", backends: [TestBackend]) == []
  end
end

