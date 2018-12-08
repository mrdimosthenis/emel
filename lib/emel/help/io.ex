defmodule Emel.Help.Io do
  @moduledoc false

  alias Emel.Help.Utils

  def load_dataset(path) do
    path
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Enum.map(&Utils.identity/1)
  end
  def load_dataset(path, columns_of_interest) do
    path
    |> load_dataset()
    |> Enum.map(fn row -> Map.take(row, columns_of_interest) end)
  end

  def save_dataset([r | _] = dataset, path) do
    headers = Map.keys(r)
    rows = Enum.map(dataset, fn row -> Utils.map_vals(row, headers) end)
    file = File.open!(path, [:write, :utf8])
    [headers | rows]
    |> CSV.encode
    |> Enum.each(&IO.write(file, &1))
    File.close(file)
  end

end
