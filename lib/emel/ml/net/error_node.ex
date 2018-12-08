defmodule Emel.Ml.Net.ErrorNode do
  @moduledoc false

  import List, only: [replace_at: 3]

  alias Emel.Help.Utils

  use GenServer

  defmodule State do
    @moduledoc false
    defstruct [:x_pids, :xs, :y_pids, :ys]
  end

  # Client

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def set_x_pids(pid, x_pids) do
    GenServer.call(pid, {:set_x_pids, x_pids})
  end

  def set_y_pids(pid, y_pids) do
    GenServer.call(pid, {:set_y_pids, y_pids})
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  # Server (callbacks)

  @impl true

  def init(n) do
    xs = Utils.duplicate(nil, n)
    ys = Utils.duplicate(nil, n)
    state = %State{xs: xs, ys: ys}
    {:ok, state}
  end

  @impl true

  def handle_call({:set_x_pids, x_pids}, _from, state) do
    new_state = %{state | x_pids: x_pids}
    {:reply, :ok, new_state}
  end

  def handle_call({:set_y_pids, y_pids}, _from, state) do
    new_state = %{state | y_pids: y_pids}
    {:reply, :ok, new_state}
  end

  @impl true

  def handle_info(
        {:fire, x_pid, x_val},
        %State{
          x_pids: x_pids,
          xs: xs
        } = state
      ) do
    index = Enum.find_index(x_pids, fn pid -> pid == x_pid end)
    temp_xs = replace_at(xs, index, x_val)
    temp_state = %{state | xs: temp_xs}
    {new_xs, new_ys} = maybe_back_propagate(temp_state)
    new_state = %{state | xs: new_xs, ys: new_ys}
    {:noreply, new_state}
  end

  def handle_info(
        {:fire_y, y_pid, y_val},
        %State{
          y_pids: y_pids,
          ys: ys
        } = state
      ) do
    index = Enum.find_index(y_pids, fn pid -> pid == y_pid end)
    temp_ys = replace_at(ys, index, y_val)
    temp_state = %{state | ys: temp_ys}
    {new_xs, new_ys} = maybe_back_propagate(temp_state)
    new_state = %{state | xs: new_xs, ys: new_ys}
    {:noreply, new_state}
  end

  # helper functions

  defp maybe_back_propagate(
         %State{
           x_pids: x_pids,
           xs: xs,
           y_pids: y_pids,
           ys: ys
         }
       ) do
    case Enum.all?(xs, fn x -> x != nil end) && Enum.all?(ys, fn y -> y != nil end) do
      true -> Enum.zip([x_pids, xs, y_pids, ys])
              |> Enum.each(
                   fn {x_pid, x, y_pid, y} ->
                     delta = (-2) * (y - x)
                     send(x_pid, {:back_propagate, self(), delta})
                     send(y_pid, {:back_propagate, self(), delta})
                   end
                 )
              new_xs = Enum.map(xs, fn _ -> nil end)
              new_ys = Enum.map(ys, fn _ -> nil end)
              {new_xs, new_ys}
      _ -> {xs, ys}
    end
  end

end
