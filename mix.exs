defmodule BusBar.Mixfile do
  use Mix.Project

  def project do
    [
      app:             :bus_bar,
      version:         "0.0.2",
      elixir:          "~> 1.2",
      build_embedded:  Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps:            deps,
      description:     description,
      package:         package,
    ]
  end

  def application do
    [
      applications: [:logger],
      mod: { BusBar, [] },
    ]
  end

  defp deps do
    [
      { :dogma,   "~> 0.1.5", only: :dev },
      { :ex_doc,  ">= 0.0.0", only: :dev },
      { :earmark, ">= 0.0.0", only: :dev },
    ]
  end

  defp description do
    """
    A simple event bus.
    """
  end

  defp package do
    [
      name:        :bus_bar,
      files:       ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Jon Rowe"],
      licenses:    ["MIT"],
      links:       %{ "GitHub" => "https://github.com/JonRowe/busbar" },
    ]
  end
end
