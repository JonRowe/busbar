# BusBar

Simple event bus for elixir.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add bus_bar to your list of dependencies in `mix.exs`:

        def deps do
          [{:bus_bar, "~> 0.0.1"}]
        end

  2. Ensure bus_bar is started before your application:

        def application do
          [applications: [:bus_bar]]
        end

