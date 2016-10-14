defmodule BusBar.Mains do
  @moduledoc false

  def start_link do
    { :ok, pid } = GenEvent.start_link([])
    Agent.start_link(fn -> pid end, name: __MODULE__)
    { :ok, pid }
  end

  def notify(event, data \\ nil) do
    bus_process
    |> GenEvent.notify({event, data})
  end

  def attach(listener, args \\ []) do
    bus_process
    |> GenEvent.add_handler(listener, args)
  end

  def listeners do
    bus_process |> GenEvent.which_handlers
  end

  def sync(event) do
    bus_process |> GenEvent.sync_notify(event)
  end

  defp bus_process do
    Agent.get(__MODULE__, fn (pid) -> pid end)
  end

end
