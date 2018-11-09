defmodule Math.Statistics do
  @moduledoc false

  alias Help.Utils

  @doc ~S"""
  The ratio of same values between `vector_a` and `vector_b`.

  ## Examples

      iex> Math.Statistics.similarity(["a", "b", "b", "a"], ["a", "b", "b", "b"])
      0.75

      iex> Math.Statistics.similarity(["d", "b", "d", "a"], ["a", "b", "c", "d"])
      0.25

  """
  def similarity(vector_a, vector_b) when length(vector_a) == length(vector_b) do
    n = Enum.zip(vector_a, vector_b)
        |> Enum.count(fn {a, b} -> a == b end)
    n / length(vector_b)
  end

  @doc ~S"""
  A measure of difference between two continuous variables.

  ## Examples

      iex> Math.Statistics.mean_absolute_error([0.0, 1.0], [0.0, 1.0])
      0.0

      iex> Math.Statistics.mean_absolute_error([5.0, 1.0, 0.0, 0.5], [0.0, 1.0, -3.0, 0.5])
      2.0

  """
  def mean_absolute_error(predictions, observations) when length(predictions) == length(observations) do
    sum_absolute_error = Enum.zip(predictions, observations)
                         |> Enum.map(fn {v1, v2} -> abs(v1 - v2) end)
                         |> Enum.sum()
    sum_absolute_error / length(observations)
  end

  @doc ~S"""
  A number that gives you an idea of how random an outcome will be based on the `probability_values`
  of each of the possible outcomes in a situation.

  ## Examples

      iex> Math.Statistics.entropy([0.5, 0.5])
      1.0

      iex> Math.Statistics.entropy([0.999, 0.001])
      0.011407757737461138

      iex> Math.Statistics.entropy([0.25, 0.25, 0.25, 0.25])
      1.0

      iex> Math.Statistics.entropy([0.8, 0.05, 0.05, 0.1])
      0.5109640474436812

  """
  def entropy([1.0]), do: 0.0
  def entropy(probability_values) do
    Enum.each(
      probability_values,
      fn
        p ->
          if p <= 0.0 || p >= 1 do
            raise "Probability is not less than 1.0 or greater that 0.0" end
      end
    )
    base = length(probability_values)
    probability_values
    |> Enum.map(fn p -> (-p) * Utils.log(p, base) end)
    |> Enum.sum()
  end

  @doc ~S"""
  The probability of event A occurring given that event B has occurred.

  ## Examples

      iex> Math.Statistics.posterior_probability(0.8, 0.4, 0.5)
      0.25

      iex> Math.Statistics.posterior_probability(0.4, 0.5, 0.1)
      0.125

  """
  def posterior_probability(prior_probability_B, prior_probability_A, probability_B_given_A) do
    probability_B_given_A * prior_probability_A / prior_probability_B
  end

end
