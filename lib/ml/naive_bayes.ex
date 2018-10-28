defmodule Ml.NaiveBayes do
  @moduledoc ~S"""
  A simple _probabilistic classifier_ based on applying _Bayes' theorem_
  with naive independence assumptions between the features.
  It makes classifications using the maximum _posteriori_ decision rule in a Bayesian setting.

  """

  def prior_probability(observations, attribute, value) do
    denominator = length(observations)
    numerator = observations
    |> Enum.filter(fn %{^attribute => val} -> val == value end)
    |> length()
    numerator / denominator
  end

  def probability_B_given_A(observations, attribute_B, value_B, attribute_A, value_A) do
    observations
    |> Enum.filter(fn %{^attribute_A => val} -> val == value_A end)
    |> prior_probability(attribute_B, value_B)
  end

end
