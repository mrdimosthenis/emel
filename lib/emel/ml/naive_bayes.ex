defmodule Emel.Ml.NaiveBayes do
  @moduledoc """
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

  def combined_posterior_probability(observations, values_by_attribute_B_map, attribute_A, value_A) do
    probability_a = prior_probability(observations, attribute_A, value_A)
    combined_posterior = Enum.reduce(
      values_by_attribute_B_map,
      1,
      fn ({attr, val}, acc) ->
        b_given_a = probability_B_given_A(observations, attr, val, attribute_A, value_A)
        acc * b_given_a
      end
    )
    probability_a * combined_posterior
  end

  @doc """
  Returns the function that classifies an item by using the _Naive Bayes Algorithm_.

  ## Examples

      iex> f = Emel.Ml.NaiveBayes.classifier([
      ...>         %{outlook: "Sunny", temperature: "Hot", humidity: "High", wind: "Weak", decision: "No"},
      ...>         %{outlook: "Sunny", temperature: "Hot", humidity: "High", wind: "Strong", decision: "No"},
      ...>         %{outlook: "Overcast", temperature: "Hot", humidity: "High", wind: "Weak", decision: "Yes"},
      ...>         %{outlook: "Rain", temperature: "Mild", humidity: "High", wind: "Weak", decision: "Yes"},
      ...>         %{outlook: "Rain", temperature: "Cool", humidity: "Normal", wind: "Weak", decision: "Yes"},
      ...>         %{outlook: "Rain", temperature: "Cool", humidity: "Normal", wind: "Strong", decision: "No"},
      ...>         %{outlook: "Overcast", temperature: "Cool", humidity: "Normal", wind: "Strong", decision: "Yes"},
      ...>         %{outlook: "Sunny", temperature: "Mild", humidity: "High", wind: "Weak", decision: "No"},
      ...>         %{outlook: "Sunny", temperature: "Cool", humidity: "Normal", wind: "Weak", decision: "Yes"},
      ...>         %{outlook: "Rain", temperature: "Mild", humidity: "Normal", wind: "Weak", decision: "Yes"},
      ...>         %{outlook: "Sunny", temperature: "Mild", humidity: "Normal", wind: "Strong", decision: "Yes"},
      ...>         %{outlook: "Overcast", temperature: "Mild", humidity: "High", wind: "Strong", decision: "Yes"},
      ...>         %{outlook: "Overcast", temperature: "Hot", humidity: "Normal", wind: "Weak", decision: "Yes"},
      ...>         %{outlook: "Rain", temperature: "Mild", humidity: "High", wind: "Strong", decision: "No"}
      ...>    ], [:outlook, :temperature, :humidity, :wind], :decision)
      ...> f.(%{outlook: "Sunny", temperature: "Mild", humidity: "Normal", wind: "Strong"})
      "Yes"

  """
  def classifier(dataset, discrete_attributes, class) do
    class_values = dataset
                   |> Enum.map(fn %{^class => val} -> val end)
                   |> Enum.uniq()
    fn item ->
      values_by_attribute_map = Map.take(item, discrete_attributes)
      Enum.max_by(
        class_values,
        fn class_val ->
          combined_posterior_probability(dataset, values_by_attribute_map, class, class_val)
        end
      )
    end
  end

end
