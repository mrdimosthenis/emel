defmodule Ml.Net.Neuron do
  @moduledoc false

  alias Help.Utils
  alias Math.Geometry
  alias Math.Calculus

  use GenServer

  defmodule State do
    @moduledoc false
    defstruct [:ws, :xpids_with_vals, :ypids]
  end

  # Client

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def fire(pid, xpid, xval) do
    GenServer.cast(pid, {:fire, xpid, xval})
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  # Server (callbacks)

  @impl true
  def init([ws, ypids]) do
    state = %State{ws: ws, ypids: ypids}
    {:ok, state}
  end

  @impl true
  def handle_cast({:fire, xpid, xval}, %State{ws: ws, xpids_with_vals: xpids_with_vals, ypids: ypids} = state) do
    new_xpids_with_vals = Utils.put_into_keylist(xpids_with_vals, xpid, xval)
    final_xpids_with_vals = if Enum.count(new_xpids_with_vals) == length(ws) &&
                                 Enum.all?(new_xpids_with_vals, fn {_, x} -> x != nil end) do
      y = new_xpids_with_vals
          |> Enum.map(fn {_, x} -> x end)
          |> Geometry.dot_product(ws)
          |> Calculus.logistic_function()
      Enum.each(ypids, fn {ypid, _} -> fire(ypid, self(), y) end)
      Enum.map(new_xpids_with_vals, fn {xpids, _} -> {xpids, nil} end)
    else
      new_xpids_with_vals
    end
    new_state = %{state | xpids_with_vals: final_xpids_with_vals}
    {:noreply, new_state}
  end

end
