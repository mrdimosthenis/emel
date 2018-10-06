defmodule Help.Utils do
  @moduledoc false

  def identity(x), do: x

  @doc ~S"""
  The list of all indices of `ls`.

  ## Examples

      iex> Help.Utils.indices([])
      []

      iex> Help.Utils.indices([3, 7, 9])
      [0, 1, 2]

      iex> Help.Utils.indices(["b", "c", "d", "a", "e"])
      [0, 1, 2, 3, 4]

  """
  def indices([]), do: []
  def indices(ls), do: Enum.map(0 .. length(ls) - 1, &identity/1)

end
