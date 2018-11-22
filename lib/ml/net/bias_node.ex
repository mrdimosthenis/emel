defmodule Ml.Net.BiasNode do
  @moduledoc false

  use GenServer

  # Client

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  # Server (callbacks)

  @impl true
  def init(ypids) do
    Enum.each(ypids, fn ypid -> send(ypid, {:fire, self(), 1.0}) end)
    {:ok, ypids}
  end

  @impl true

  def handle_info({:back_propagate, ypid, _}, ypids) do
    send(ypid, {:fire, self(), 1.0})
    {:noreply, ypids}
  end

end
