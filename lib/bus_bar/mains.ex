defmodule BusBar.Mains do
  @moduledoc """
  The mains is responsible for connecting events.
  """

  def start_link do
    { :ok, pid } = GenEvent.start_link([])
    Agent.start_link(fn -> pid end, name: __MODULE__)
    { :ok, pid }
  end

  def attach(listener, args \\ []) do
    bus_process
    |> GenEvent.add_handler(listener, args)
  end

  defp bus_process do
    Agent.get(__MODULE__, fn (pid) -> pid end)
  end

end
