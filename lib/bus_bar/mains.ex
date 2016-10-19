defmodule BusBar.Mains do
  @moduledoc """
  The Mains module implements an event manager using Agent and GenEvent.
  """

  require Logger

  def start_link do
    GenEvent.start_link([name: :bus_bar])
  end

  def notify(event, data \\ nil) do
    Logger.debug "BusBar NOTIFY #{event}"
    :ok = GenEvent.ack_notify(:bus_bar, {event, data})
  end

  def attach(listener) do
    Logger.debug "BusBar ATTACH #{listener}"
    :ok = GenEvent.add_mon_handler(:bus_bar, listener, [])
  end

  def detach(listener) do
    Logger.debug "BusBar DETACH #{listener}"
    GenEvent.remove_handler(:bus_bar, listener, [])
  end

  def listeners do
    GenEvent.which_handlers :bus_bar
  end

  def sync_notify(event, data) do
    Logger.debug "BusBar SYNC NOTIFY #{event}"
    :ok = GenEvent.sync_notify(:bus_bar, {event, data})
  end

end
