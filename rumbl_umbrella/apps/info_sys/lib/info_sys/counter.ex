defmodule InfoSys.Counter do
  use GenServer, restart: :transient

  def inc(pid), do: GenServer.cast(pid, :inc)

  def dec(pid), do: GenServer.cast(pid, :dec)

  def val(pid) do
    GenServer.call(pid, :val)
  end

  def start_link(initial_val) do
    GenServer.start_link(__MODULE__, initial_val)
  end

  def init(initial_val) do
    {:ok, initial_val}
  end

  defp interval_process() do
    Process.send_after(self(), :tick, 1000)
  end

  def handle_info(:tick, val) when val < 0, do: {:error, "Boom!"}

  def handle_info(:tick, val) do
    IO.puts('#{val}')
    interval_process();
    {:noreply, val - 1}
  end

  def handle_cast(:inc, val) do
    {:noreply, val + 1}
  end

  def handle_cast(:dec, val) do
    {:noreply, val - 1}
  end

  def handle_call(:val, _from, val) do
    {:reply, val, val}
  end
end