defmodule Ml.ArtificialNeuron do
  @moduledoc """
  A mathematical function conceived as a model of biological neurons.
  Receives one or more separately weighted inputs, sums them and passes the sum through an _activation function_ to
  produce an output.

  """

  alias Math.Calculus
  alias Math.Geometry

  defmodule Neuron do
    @moduledoc false
    @enforce_keys [:ws, :f, :f_deriv]
    defstruct [:ws, :f, :f_deriv]

    def new(ws, f \\ &Calculus.logistic_function/1, f_deriv \\ &Calculus.logistic_derivative/1) do
      weights = if is_number(ws) do
        for _ <- 1..ws do
          :rand.uniform()
        end
      else
        ws
      end

      %Neuron{ws: weights, f: f, f_deriv: f_deriv}
    end
  end

  def neuron_output(xs, %Neuron{ws: ws, f: f}) do
    xs
    |> Geometry.dot_product(ws)
    |> f.()
  end

end
