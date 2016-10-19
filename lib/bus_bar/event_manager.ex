defmodule BusBar.EventManager do
  @moduledoc """
  The EventManager module manages GenEvent for BusBar consumers.
  """

  require Logger

  def start_link do
    GenEvent.start_link([name: :bus_bar_events])
  end

  def notify(event, data \\ nil) do
    Logger.debug "BusBar NOTIFY #{event}"
    :ok = GenEvent.ack_notify(:bus_bar_events, {event, data})
  end

  def attach(listener) do
    Logger.debug "BusBar ATTACH #{listener}"
    :ok = GenEvent.add_mon_handler(:bus_bar_events, listener, [])
  end

  def detach(listener) do
    Logger.debug "BusBar DETACH #{listener}"
    GenEvent.remove_handler(:bus_bar_events, listener, [])
  end

  def listeners do
    GenEvent.which_handlers :bus_bar_events
  end

  def sync_notify(event, data) do
    Logger.debug "BusBar SYNC NOTIFY #{event}"
    :ok = GenEvent.sync_notify(:bus_bar_events, {event, data})
  end

end
