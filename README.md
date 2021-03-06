# BusBar
[![Build Status](https://travis-ci.org/JonRowe/busbar.svg?branch=master)](https://travis-ci.org/JonRowe/busbar)

Simple event bus for elixir.

## Usage

```Elixir
defmodule MyListener do
  require Logger

  def handle_event({:some_event, message }, state) do
    Logger.info "Notified of #{message}"
    { :ok, state }
  end
end

BusBar.attach MyListener

BusBar.notify :some_event, 'my_data'
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add bus_bar to your list of dependencies in `mix.exs`:

        def deps do
          [{:bus_bar, "~> 0.0.2"}]
        end

  2. Ensure bus_bar is started before your application:

        def application do
          [applications: [:bus_bar]]
        end

