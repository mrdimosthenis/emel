defmodule Ml.Net.Neuron do
  @moduledoc false

  import List, only: [replace_at: 3]

  alias Help.Utils
  alias Math.Geometry
  alias Math.Calculus

  use GenServer

  defmodule State do
    @moduledoc false
    defstruct [:ws, :x_pids, :xs, :y_pids, :ys, :fit, :a]
  end

  # Client

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def set_ws(pid, ws) do
    GenServer.call(pid, {:set_ws, ws})
  end

  def get_ws(pid) do
    GenServer.call(pid, :get_ws)
  end

  def set_x_pids(pid, x_pids) do
    GenServer.call(pid, {:set_x_pids, x_pids})
  end

  def set_y_pids(pid, y_pids) do
    GenServer.call(pid, {:set_y_pids, y_pids})
  end

  def set_fit(pid, fit) do
    GenServer.call(pid, {:set_fit, fit})
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  # Server (callbacks)

  @impl true

  def init([xn, yn, a]) do
    ws = Utils.rand_float(xn)
    xs = Utils.duplicate(nil, xn)
    ys = Utils.duplicate(nil, yn)
    state = %State{ws: ws, xs: xs, ys: ys, fit: true, a: a}
    {:ok, state}
  end

  def init([xn, yn]) do
    ws = Utils.rand_float(xn)
    xs = Utils.duplicate(nil, xn)
    ys = Utils.duplicate(nil, yn)
    state = %State{ws: ws, xs: xs, ys: ys, fit: false}
    {:ok, state}
  end

  @impl true

  def handle_call({:set_ws, ws}, _from, state) do
    new_state = %{state | ws: ws}
    {:reply, :ok, new_state}
  end

  def handle_call(:get_ws, _from, %State{ws: ws} = state) do
    {:reply, ws, state}
  end

  def handle_call({:set_x_pids, x_pids}, _from, state) do
    new_state = %{state | x_pids: x_pids}
    {:reply, :ok, new_state}
  end

  def handle_call({:set_y_pids, y_pids}, _from, state) do
    new_state = %{state | y_pids: y_pids}
    {:reply, :ok, new_state}
  end

  def handle_call({:set_fit, fit}, _from, state) do
    new_state = %{state | fit: fit}
    {:reply, :ok, new_state}
  end

  @impl true

  def handle_info(
        {:fire, x_pid, x_val},
        %State{
          ws: ws,
          x_pids: x_pids,
          xs: xs,
          y_pids: y_pids,
          fit: fit
        } = state
      ) do
    index = Enum.find_index(x_pids, fn pid -> pid == x_pid end)
    temp_xs = replace_at(xs, index, x_val)
    new_xs = case Enum.all?(temp_xs, fn x -> x != nil end) do
      true -> y_val = Geometry.dot_product(ws, temp_xs)
                      |> Calculus.logistic_function()
              Enum.each(y_pids, fn pid -> send(pid, {:fire, self(), y_val}) end)
              case fit do
                true -> temp_xs
                false -> Enum.map(temp_xs, fn _ -> nil end)
              end
      _ -> temp_xs
    end
    new_state = %{state | xs: new_xs}
    {:noreply, new_state}
  end

  def handle_info(
        {:back_propagate, y_pid, y_val},
        %State{
          ws: ws,
          x_pids: x_pids,
          xs: xs,
          ys: ys,
          y_pids: y_pids,
          a: a
        } = state
      ) do
    index = Enum.find_index(y_pids, fn pid -> pid == y_pid end)
    temp_ys = List.replace_at(ys, index, y_val)
    {new_ws, new_xs, new_ys} = case Enum.all?(temp_ys, fn y -> y != nil end) do
      true -> theta = Geometry.dot_product(ws, xs)
                      |> Calculus.logistic_function()
              delta = Enum.sum(temp_ys)
              common_factor = delta * Calculus.logistic_derivative(theta)
              Enum.zip(x_pids, ws)
              |> Enum.each(fn {pid, w} -> send(pid, {:back_propagate, self(), common_factor * w}) end)
              ws_ = Enum.zip(xs, ws)
                    |> Enum.map(fn {x, w} -> w - a * common_factor * x end)
              xs_ = Enum.map(xs, fn _ -> nil end)
              ys_ = Enum.map(temp_ys, fn _ -> nil end)
              {ws_, xs_, ys_}
      _ -> {ws, xs, temp_ys}
    end
    new_state = %{state | ws: new_ws, xs: new_xs, ys: new_ys}
    {:noreply, new_state}
  end

end
