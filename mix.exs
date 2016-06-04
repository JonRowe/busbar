defmodule BusBar.Mixfile do
  use Mix.Project

  def project do
    [
      app:             :bus_bar,
      version:         "0.0.1",
      elixir:          "~> 1.2",
      build_embedded:  Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps:            deps,
      description:     description,
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
      { :dogma, "~> 0.1.5", only: [:dev] },
    ]
  end

  defp description do
    """
    A simple event bus.
    """
  end
end
