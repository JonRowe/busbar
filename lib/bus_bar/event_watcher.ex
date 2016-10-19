defmodule BusBar.EventWatcher do
  @moduledoc """
  The BusBar.EventWatcher module observes events in order to
  handle fault tolerance.
  """

  use GenServer
  require Logger

  def start_link(manager) do
    { :ok, pid } = GenServer.start_link(__MODULE__, manager)
    { :ok, pid }
  end

  def init(manager) do
    Process.monitor(manager)
    { :ok, manager }
  end

  def handle_info({:DOWN, _, _, {BusBar.EventManager, _}, reason}, source) do
    Logger.debug "Stopping watching BusBar events due to #{inspect reason} " <>
                 "on #{inspect source}"
    {:stop, 'BusBar down.', []}
  end

  def handle_info({:gen_event_EXIT, handler, reason}, manager) do
    Logger.debug "Restarting #{inspect handler} due to #{inspect reason}."
    BusBar.EventManager.attach handler
    { :noreply, manager }
  end

end
