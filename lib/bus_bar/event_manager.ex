defmodule BusBar.EventManager do
  @moduledoc """
  The EventManager module manages events for BusBar consumers.
  """

  require Logger

  alias BusBar.EventHandler
  alias BusBar.Supervisor

  def start_link do
    {:ok, self()}
  end

  def attach(listener) do
    Logger.debug "BusBar ATTACH #{listener}"
    {:ok, _pid} = Supervisor.add(EventHandler, [listener], id: listener)
    :ok
  end

  def detach(listener) do
    Logger.debug "BusBar DETACH #{listener}"
    :ok = Supervisor.remove listener
  end

  def listeners(_ \\ [])
  def listeners(with_pids: true) do
    Supervisor.children
    |> Enum.map(fn({id, pid, _status, [_event_handler]}) -> {id, pid} end)
  end

  def listeners(_) do
    Supervisor.children
    |> Enum.map(fn({id, _pid, _status, [_event_handler]}) -> id end)
  end

  def notify(event, data \\ nil) do
    Logger.debug "BusBar NOTIFY #{event}"
    for {_, pid, _, _} <- Supervisor.children do
      GenServer.cast(pid, {event, data})
    end
    :ok
  end

  def sync_notify(event, data) do
    Logger.debug "BusBar SYNC NOTIFY #{event}"
    for {_, pid, _, [_handler]} <- Supervisor.children do
      GenServer.call(pid, {event, data})
    end
    :ok
  end

end
