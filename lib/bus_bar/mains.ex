defmodule BusBar.Mains do
  @moduledoc """
  The Mains module implements an event manager using Agent and GenEvent.
  """

  require Logger

  def start_link do
    { :ok, pid } = GenEvent.start_link([])
    { :ok, agent_pid } = Agent.start_link(fn -> pid end, name: __MODULE__)
    Logger.debug "Started BusBar GenEvent at #{inspect pid} " <>
                 "with Agent #{inspect agent_pid}."
    { :ok, pid }
  end

  def notify(event, data \\ nil) do
    Logger.debug "BusBar NOTIFY #{event}"
    :ok = bus_process
    |> GenEvent.notify({event, data})
  end

  def attach(listener, args \\ []) do
    Logger.debug "BusBar ATTACH #{listener}"
    :ok = bus_process
    |> GenEvent.add_handler(listener, args)
  end

  def detach(listener, args \\ []) do
    Logger.debug "BusBar DETACH #{listener}"
    bus_process
    |> GenEvent.remove_handler(listener, args)
  end

  def listeners do
    bus_process |> GenEvent.which_handlers
  end

  def sync(event) do
    Logger.debug "BusBar SYNC #{event}"
    :ok = bus_process |> GenEvent.sync_notify(event)
  end

  defp bus_process do
    Agent.get(__MODULE__, fn (pid) -> pid end)
  end

end
