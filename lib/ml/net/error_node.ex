defmodule Ml.Net.ErrorNode do
  @moduledoc false

  alias Ml.Net.FitNeuron

  use GenServer

  defmodule State do
    @moduledoc false
    defstruct [:n, :vals_and_hats_by_yhatpid]
  end

  # Client

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def fire_y(pid, yhatpid, yval) do
    GenServer.cast(pid, {:fire_y, yhatpid, yval})
  end

  def fire_y_hat(pid, yhatpid, yhatval) do
    GenServer.cast(pid, {:fire_y_hat, yhatpid, yhatval})
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  # Server (callbacks)

  @impl true
  def init(n) do
    state = %State{n: n, vals_and_hats_by_yhatpid: %{}}
    {:ok, state}
  end

  @impl true
  def handle_cast(
        {:fire_y, yhatpid, yval},
        %State{vals_and_hats_by_yhatpid: vals_and_hats_by_yhatpid} = state
      ) do
    old_vals_and_hats = vals_and_hats_by_yhatpid[yhatpid]
    new_vals_and_hats = case old_vals_and_hats do
      nil -> %{y: yval}
      %{} = map -> Map.put(map, :y, yval)
    end
    new_vals_and_hats_by_yhatpid = Map.put(vals_and_hats_by_yhatpid, yhatpid, new_vals_and_hats)
    new_state = %{state | vals_and_hats_by_yhatpid: new_vals_and_hats_by_yhatpid}
    maybe_back_propagate(new_state)
  end
  def handle_cast(
        {:fire_y_hat, yhatpid, yhatval},
        %State{vals_and_hats_by_yhatpid: vals_and_hats_by_yhatpid} = state
      ) do
    old_vals_and_hats = vals_and_hats_by_yhatpid[yhatpid]
    new_vals_and_hats = case old_vals_and_hats do
      nil -> %{yhat: yhatval}
      %{} = map -> Map.put(map, :yhat, yhatval)
    end
    new_vals_and_hats_by_yhatpid = Map.put(vals_and_hats_by_yhatpid, yhatpid, new_vals_and_hats)
    new_state = %{state | vals_and_hats_by_yhatpid: new_vals_and_hats_by_yhatpid}
    maybe_back_propagate(new_state)
  end

  # helper functions
  defp maybe_back_propagate(%State{n: n, vals_and_hats_by_yhatpid: vals_and_hats_by_yhatpid} = state) do
    new_state = if Enum.count(vals_and_hats_by_yhatpid) == n &&
                     Enum.all?(
                       vals_and_hats_by_yhatpid,
                       fn {_, vals_and_hats} -> vals_and_hats[:y] != nil && vals_and_hats[:yhat] != nil end
                     ) do
      for {yhatpid, %{y: y, yhat: yhat}} <- vals_and_hats_by_yhatpid do
        delta = (-2) * (y - yhat)
        FitNeuron.back_propagate(yhatpid, self(), delta)
      end
      %{state | vals_and_hats_by_yhatpid: %{}}
    else
      state
    end
    {:noreply, new_state}
  end

end
