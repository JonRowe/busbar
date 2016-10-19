defmodule BusBar.EventWatcher do
  @moduledoc """
  The BusBar.EventWatcher module observes events in order to
  handle fault tolerance.
  """

  require Logger

  def start_link(handler) do
    GenServer.start_link(__MODULE__, handler)
    { :ok, handler }
  end

  def init(handler) do
    BusBar.EventManager.attach handler
    { :ok, handler }
  end

  def handle_info({:DOWN, _, _, {BusBar.EventManager, _}, reason}, source) do
    Logger.debug "Stopping watching BusBar events due to #{inspect reason} " <>
                 "on #{inspect source}"
    {:stop, 'BusBar down.', []}
  end

  def handle_info({:gen_event_EXIT, _handler, :normal}, state) do
    { :noreply, state }
  end

  def handle_info({:gen_event_EXIT, _handler, :shutdown}, state) do
    { :noreply, state }
  end

  def handle_info({:gen_event_EXIT, handler, _reason}, state) do
    Logger.debug "Restarting #{inspect handler}."
    BusBar.EventManager.attach handler
    { :noreply, state }
  end

end
