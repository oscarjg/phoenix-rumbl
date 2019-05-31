defmodule InfoSys.CounterAgent do
  use Agent, restart: :permanent

  @agent_name __MODULE__

  def start_link(initial_val) do
    Agent.start_link(fn -> initial_val end, name: @agent_name)
  end

  def value() do
    Agent.get(@agent_name, fn state -> state end)
  end

  def increase() do
    Agent.get_and_update(@agent_name, fn state -> {state, state + 1} end)
  end

  def decrease() do
    Agent.get_and_update(@agent_name, fn state -> {state, state - 1} end)
  end
end