defmodule Ml.Net.Wrapper do
  @moduledoc false

  alias Ml.Net.InputNode
  alias Ml.Net.Neuron
  alias Ml.Net.OutputNode

  use GenServer

  defmodule State do
    @moduledoc false
    defstruct [:x_pids, :y_pid, :b_pid, :neuron_pids]
  end

  # Client

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def predict(pid, xs) do
    GenServer.call(pid, {:predict, xs})
  end

  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  def with(wrapper_config, f) do
    {:ok, wrapper} = start_link(wrapper_config)
    result = f.(wrapper)
    stop(wrapper)
    result
  end

  # Server (callbacks)

  @impl true

  def init([[first_layer | _] = weights, yn]) do
    xn = first_layer
         |> Enum.at(0)
         |> Enum.drop(-1)
         |> Enum.count()
    x_pids = for _ <- 1..xn do
      {:ok, input_node} = GenServer.start_link(InputNode, length(first_layer))
      input_node
    end

    num_of_neurons = weights
                     |> Enum.concat()
                     |> Enum.count()
    {:ok, b_pid} = GenServer.start_link(InputNode, num_of_neurons)

    layer_last_index = length(weights) - 1

    neuron_pids = for {layer, index} <- Enum.with_index(weights) do
      for ws <- layer do
        num_of_outputs = case index do
          ^layer_last_index -> 1
          _ -> weights
               |> Enum.at(index + 1)
               |> Enum.count()
        end
        {:ok, neuron} = GenServer.start_link(Neuron, [ws, num_of_outputs])
        neuron
      end
    end

    {:ok, y_pid} = GenServer.start_link(OutputNode, yn)

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
          ^layer_last_index -> [y_pid]
          _ -> Enum.at(neuron_pids, index + 1)
        end
        Neuron.set_x_pids(pid, neuron_x_pids)
        Neuron.set_y_pids(pid, neuron_y_pids)
      end
    end

    OutputNode.set_x_pids(y_pid, Enum.at(neuron_pids, layer_last_index))
    OutputNode.set_y_pid(y_pid, self())

    state = %State{x_pids: x_pids, y_pid: y_pid, b_pid: b_pid, neuron_pids: neuron_pids}
    {:ok, state}
  end

  @impl true

  def handle_call(
        {:predict, xs},
        _from,
        %State{x_pids: x_pids, b_pid: b_pid} = state
      ) do
    Enum.zip(x_pids, xs)
    |> Enum.each(fn {pid, x} -> send(pid, {:fire, self(), x}) end)

    send(b_pid, {:fire, self(), 1.0})

    prediction = receive do
      {:fire, _, pred_vec} -> pred_vec
    end

    {:reply, prediction, state}
  end

  def handle_call(:stop, _from, %State{x_pids: x_pids, y_pid: y_pid, b_pid: b_pid, neuron_pids: neuron_pids} = state) do
    Enum.each(x_pids, fn pid -> InputNode.stop(pid) end)
    OutputNode.stop(y_pid)
    InputNode.stop(b_pid)
    neuron_pids
    |> Enum.concat()
    |> Enum.each(fn pid -> Neuron.stop(pid) end)
    {:reply, :ok, state}
  end

end
