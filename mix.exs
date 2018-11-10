defmodule Emel.MixProject do
  use Mix.Project

  def project do
    [
      app: :emel,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "emel",
      source_url: "https://github.com/mrdimosthenis/emel",
      docs: [
        main: "Emel",
        # The main page in the docs
      ],

      description: "Turn data into functions! A simple and functional machine learning library written in elixir.",
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:csv, "~> 2.0.0"},
      {:earmark, "~> 1.2", only: :dev},
      {:ex_doc, "~> 0.19", only: :dev}
    ]
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "emel",
      # These are the default files included in the package
      # files: ~w(lib priv .formatter.exs mix.exs README* readme* LICENSE*
      #           license* CHANGELOG* changelog* src),
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/mrdimosthenis/emel"
      }
    ]
  end

end
