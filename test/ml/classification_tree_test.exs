defmodule ClassificationTreeTest do
  use ExUnit.Case
  doctest Ml.ClassificationTree
  import Ml.ClassificationTree

  @a [
    %{outlook: "s", windy: "f", golf: "y"},
    %{outlook: "s", windy: "f", golf: "y"},
    %{outlook: "s", windy: "f", golf: "y"},
    %{outlook: "o", windy: "f", golf: "y"},
    %{outlook: "o", windy: "f", golf: "y"},
    %{outlook: "o", windy: "t", golf: "y"},
    %{outlook: "o", windy: "t", golf: "y"},
    %{outlook: "r", windy: "f", golf: "y"},
    %{outlook: "r", windy: "t", golf: "y"},
    %{outlook: "s", windy: "t", golf: "n"},
    %{outlook: "s", windy: "t", golf: "n"},
    %{outlook: "r", windy: "f", golf: "n"},
    %{outlook: "r", windy: "f", golf: "n"},
    %{outlook: "r", windy: "t", golf: "n"}
  ]

  test "target attribute entropy" do
    assert entropy(@a, :golf) == 0.9402859586706309
  end

  test "information gain" do
    assert information_gain(@a, :golf, :outlook) == 0.2467498197744391
  end

  test "decision tree" do
    assert decision_tree(@a, :golf, [:outlook, :windy]) ==
             {
               %{attribute: :outlook},
               [
                 {%{value: "o"}, [%{class: "y"}]},
                 {
                   %{value: "r"},
                   [
                     {
                       %{attribute: :windy},
                       [{%{value: "f"}, [%{class: "n"}]}, {%{value: "t"}, [%{class: "n"}]}]
                     }
                   ]
                 },
                 {
                   %{value: "s"},
                   [
                     {
                       %{attribute: :windy},
                       [{%{value: "f"}, [%{class: "y"}]}, {%{value: "t"}, [%{class: "n"}]}]
                     }
                   ]
                 }
               ]
             }
  end

end
