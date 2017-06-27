defmodule BusBar.EventHandler do
  @moduledoc """
  The BusBar.EventHandler module uses GenServer to handle events.
  """

  use GenServer

  require Logger

  def start_link(handler) do
    {:ok, _child} = GenServer.start_link(__MODULE__, handler)
  end

  def init(handler) do
    Process.flag(:trap_exit, true)
    {:ok, handler}
  end

  def handle_call(message, _from, handler) do
    handler.handle_event(message, self())
    {:reply, :ok, handler}
  end

  def handle_cast(message, handler) do
    handler.handle_event(message, self())
    {:noreply, handler}
  end

  def terminate(:normal, _handler), do: :ok
  def terminate(reason, handler) do
    Logger.info "Terminating #{handler} due to #{inspect reason}."
    :ok
  end
end
