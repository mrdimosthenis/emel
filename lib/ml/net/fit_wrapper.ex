defmodule Ml.Net.FitWrapper do
  @moduledoc false

  alias Ml.Net.InputNode
  alias Ml.Net.Neuron
  alias Ml.Net.ErrorNode
  alias Help.Utils

  use GenServer

  defmodule State do
    @moduledoc false
    defstruct [:x_pids, :y_pids, :b_pid, :neuron_pids, :err_pid]
  end

  # Client

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def fit(pid, xs, ys) do
    GenServer.call(pid, {:fit, xs, ys})
  end

  def get_weights(pid) do
    GenServer.call(pid, :get_weights)
  end

  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  def with(fit_wrapper_config, f) do
    {:ok, fit_wrapper} = start_link(fit_wrapper_config)
    result = f.(fit_wrapper)
    stop(fit_wrapper)
    result
  end

  # Server (callbacks)

  @impl true

  def init([xn, yn, [first_layer | _] = layers, a]) do
    x_pids = for _ <- 1..xn do
      {:ok, input_node} = GenServer.start_link(InputNode, first_layer)
      input_node
    end

    y_pids = for _ <- 1..yn do
      Utils.useless_process()
    end

    num_of_neurons = Enum.sum(layers)
    {:ok, b_pid} = GenServer.start_link(InputNode, num_of_neurons)

    layer_last_index = length(layers) - 1

    neuron_pids = for {n, index} <- Enum.with_index(layers) do
      for _ <- 1..n do
        num_of_inputs = case index do
          0 -> xn
          _ -> Enum.at(layers, index - 1)
        end
        num_of_outputs = case index do
          ^layer_last_index -> 1
          _ -> Enum.at(layers, index + 1)
        end
        {:ok, neuron} = GenServer.start_link(Neuron, [num_of_inputs + 1, num_of_outputs, a])
        neuron
      end
    end

    {:ok, err_pid} = GenServer.start_link(ErrorNode, yn)

    for pid <- x_pids do
      InputNode.set_x_pid(pid, self())
      InputNode.set_y_pids(pid, Enum.at(neuron_pids, 0))
    end

    InputNode.set_x_pid(b_pid, self())
    InputNode.set_y_pids(b_pid, Enum.concat(neuron_pids))

    for {pids, index} <- Enum.with_index(neuron_pids) do
      for pid <- pids do
        neuron_x_pids = case index do
          0 -> x_pids ++ [b_pid]
          _ -> Enum.at(neuron_pids, index - 1) ++ [b_pid]
        end
        neuron_y_pids = case index do
          ^layer_last_index -> [err_pid]
          _ -> Enum.at(neuron_pids, index + 1)
        end
        Neuron.set_x_pids(pid, neuron_x_pids)
        Neuron.set_y_pids(pid, neuron_y_pids)
      end
    end

    ErrorNode.set_x_pids(err_pid, Enum.at(neuron_pids, layer_last_index))
    ErrorNode.set_y_pids(err_pid, y_pids)

    state = %State{x_pids: x_pids, y_pids: y_pids, b_pid: b_pid, neuron_pids: neuron_pids, err_pid: err_pid}
    {:ok, state}
  end

  @impl true

  def handle_call(
        {:fit, xs, ys},
        _from,
        %State{x_pids: x_pids, y_pids: y_pids, err_pid: err_pid, b_pid: b_pid} = state
      ) do
    Enum.zip(x_pids, xs)
    |> Enum.each(fn {pid, x} -> send(pid, {:fire, self(), x}) end)

    Enum.zip(y_pids, ys)
    |> Enum.each(fn {pid, y} -> send(err_pid, {:fire_y, pid, y}) end)

    send(b_pid, {:fire, self(), 1.0})

    for _ <- 1..length(x_pids) + 1 do
      receive do
        {:back_propagate, _, _} -> :ok
      end
    end

    {:reply, :ok, state}
  end

  def handle_call(:get_weights, _from, %State{neuron_pids: neuron_pids} = state) do
    weights = for layer <- neuron_pids do
      for pid <- layer do
        Neuron.get_ws(pid)
      end
    end
    {:reply, weights, state}
  end

  def handle_call(
        :stop,
        _from,
        %State{
          x_pids: x_pids,
          y_pids: y_pids,
          err_pid: err_pid,
          neuron_pids: neuron_pids,
          b_pid: b_pid
        } = state
      ) do
    Enum.each(x_pids, fn pid -> InputNode.stop(pid) end)
    Enum.each(y_pids, fn pid -> Process.exit(pid, :ok) end)
    ErrorNode.stop(err_pid)
    neuron_pids
    |> Enum.concat()
    |> Enum.each(fn pid -> Neuron.stop(pid) end)
    InputNode.stop(b_pid)
    {:reply, :ok, state}
  end

end
