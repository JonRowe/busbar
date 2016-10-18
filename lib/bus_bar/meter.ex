defmodule BusBar.Meter do
  @moduledoc """
  The BusBar.Meter module implement a watcher for Mains events in order to
  handle fault tolerance.
  """

  use GenServer
  require Logger

  def start_link(mains) do
    { :ok, pid } = GenServer.start_link(__MODULE__, mains)
    { :ok, pid }
  end

  def init(mains) do
    Process.monitor(mains)
    { :ok, mains }
  end

  def handle_info({:DOWN, _, _, {BusBar.Mains, _}, reason}, source) do
    Logger.debug "Stopping watching BusBar events due to #{inspect reason} " <>
                 "on #{inspect source}"
    {:stop, 'BusBar down.', []}
  end

  def handle_info({:gen_event_EXIT, handler, reason}, mains) do
    Logger.debug "Restarting #{inspect handler} due to #{inspect reason}."
    BusBar.Mains.attach handler
    { :noreply, mains }
  end

end
