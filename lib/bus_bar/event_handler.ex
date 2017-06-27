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
    handle_event(handler, message)
    {:reply, :ok, handler}
  end

  def handle_cast(message, handler) do
    handle_event(handler, message)
    {:noreply, handler}
  end

  def terminate(:normal, _handler), do: :ok
  def terminate(reason, handler) do
    Logger.info "Terminating #{handler} due to #{inspect reason}."
    :ok
  end

  defp handle_event(handler, message) do
    try do
      handler.handle_event(message, self())
    rescue
      e in RuntimeError -> handle_error(:runtime, handler, e)
      f in FunctionClauseError -> handle_error(:function, handler, f)
    end
  end

  defp handle_error(:runtime, handler, e) do
    Logger.error "Error occured in #{handler}, #{inspect e}"
    {:error, e}
  end

  defp handle_error(:function, handler, e) do
    Logger.error "Error occured in #{handler}, no function clause #{inspect e}"
    {:error, e}
  end
end
