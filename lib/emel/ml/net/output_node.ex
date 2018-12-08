defmodule Emel.Ml.Net.OutputNode do
  @moduledoc false

  import List, only: [replace_at: 3]

  alias Emel.Help.Utils

  use GenServer

  defmodule State do
    @moduledoc false
    defstruct [:x_pids, :xs, :y_pid]
  end

  # Client

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def set_x_pids(pid, x_pids) do
    GenServer.call(pid, {:set_x_pids, x_pids})
  end

  def set_y_pid(pid, y_pid) do
    GenServer.call(pid, {:set_y_pid, y_pid})
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  # Server (callbacks)

  @impl true

  def init(xn) do
    xs = Utils.duplicate(nil, xn)
    state = %State{xs: xs}
    {:ok, state}
  end

  @impl true

  def handle_call({:set_x_pids, x_pids}, _from, state) do
    new_state = %{state | x_pids: x_pids}
    {:reply, :ok, new_state}
  end

  def handle_call({:set_y_pid, y_pid}, _from, state) do
    new_state = %{state | y_pid: y_pid}
    {:reply, :ok, new_state}
  end

  @impl true

  def handle_info(
        {:fire, x_pid, x_val},
        %State{
          x_pids: x_pids,
          xs: xs,
          y_pid: y_pid
        } = state
      ) do
    index = Enum.find_index(x_pids, fn pid -> pid == x_pid end)
    temp_xs = replace_at(xs, index, x_val)
    new_xs = case Enum.all?(temp_xs, fn x -> x != nil end) do
      true -> send(y_pid, {:fire, self(), temp_xs})
              Enum.map(temp_xs, fn _ -> nil end)
      _ -> temp_xs
    end
    new_state = %{state | xs: new_xs}
    {:noreply, new_state}
  end

end
