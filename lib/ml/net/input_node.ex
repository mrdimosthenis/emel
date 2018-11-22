defmodule Ml.Net.InputNode do
  @moduledoc false

  alias Help.Utils

  use GenServer

  defmodule State do
    @moduledoc false
    defstruct [:xpid, :ypids_with_ds]
  end

  # Client

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def fire(pid, xpid, xval) do
    GenServer.cast(pid, {:fire, xpid, xval})
  end

  # Server (callbacks)

  @impl true
  def init(ypids) do
    ypids_with_ds = Enum.zip(ypids, Stream.cycle([nil]))
    state = %State{ypids_with_ds: ypids_with_ds}
    {:ok, state}
  end

  @impl true
  def handle_cast({:fire, xpid, xval}, %State{ypids_with_ds: ypids_with_ds} = state) do
    Enum.each(ypids_with_ds, fn {ypids, _} -> send(ypids, {:fire, self(), xval}) end)
    new_state = %{state | xpid: xpid}
    {:noreply, new_state}
  end

  @impl true
  def handle_info({:back_propagate, ypid, dval}, %State{xpid: xpid, ypids_with_ds: ypids_with_ds} = state) do
    new_ypids_with_ds = Utils.put_into_keylist(ypids_with_ds, ypid, dval)
    final_ypids_with_ds = if Enum.all?(new_ypids_with_ds, fn {_, d} -> is_number(d) end) do
      delta = new_ypids_with_ds
      |> Enum.map(fn {_, d} -> d end)
      |> Enum.sum()
      send(xpid, {:back_propagate, self(), delta})
      Enum.map(new_ypids_with_ds, fn {ypids, _} -> {ypids, nil} end)
    else
      new_ypids_with_ds
    end
    new_state = %{state | ypids_with_ds: final_ypids_with_ds}
    {:noreply, new_state}
  end

end
