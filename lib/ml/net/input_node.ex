defmodule Ml.Net.InputNode do
  @moduledoc false

  import List, only: [replace_at: 3]

  alias Help.Utils

  use GenServer

  defmodule State do
    @moduledoc false
    defstruct [:x_pid, :y_pids, :ys]
  end

  # Client

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def set_x_pid(pid, x_pid) do
    GenServer.call(pid, {:set_x_pid, x_pid})
  end

  def set_y_pids(pid, y_pids) do
    GenServer.call(pid, {:set_y_pids, y_pids})
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  # Server (callbacks)

  @impl true

  def init(yn) do
    ys = Utils.duplicate(nil, yn)
    state = %State{ys: ys}
    {:ok, state}
  end

  @impl true

  def handle_call({:set_x_pid, x_pid}, _from, state) do
    new_state = %{state | x_pid: x_pid}
    {:reply, :ok, new_state}
  end

  def handle_call({:set_y_pids, y_pids}, _from, state) do
    new_state = %{state | y_pids: y_pids}
    {:reply, :ok, new_state}
  end

  @impl true

  def handle_info(
        {:back_propagate, y_pid, y_val},
        %State{
          x_pid: x_pid,
          y_pids: y_pids,
          ys: ys
        } = state
      ) do
    index = Enum.find_index(y_pids, fn pid -> pid == y_pid end)
    temp_ys = replace_at(ys, index, y_val)
    new_ys = case Enum.all?(temp_ys, fn y -> y != nil end) do
      true -> send(x_pid, {:back_propagate, self(), Enum.sum(temp_ys)})
              Enum.map(temp_ys, fn _ -> nil end)
      _ -> temp_ys
    end
    new_state = %{state | ys: new_ys}
    {:noreply, new_state}
  end

  def handle_info(
        {:fire, _, x_val},
        %State{
          y_pids: y_pids
        } = state
      ) do
    Enum.each(y_pids, fn pid -> send(pid, {:fire, self(), x_val}) end)
    {:noreply, state}
  end

end
