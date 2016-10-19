defmodule BusBar do
  @moduledoc """
  BusBar receives events and dispatches them to listeners via GenEvent.
  """

  use Application

  @doc """
  Attach a listener to the bus.
  """
  def attach(listener) do
    BusBar.EventManager.attach listener
  end

  @doc """
  Detach a listener from the bus.
  """
  def detach(listener) do
    BusBar.EventManager.detach listener
  end

  @doc """
  Returns a list of currently attached listeners.
  """
  def listeners do
    BusBar.EventManager.listeners
  end

  @doc """
  Notify the bus of an event with data.
  """
  def notify(event, data) do
    BusBar.EventManager.notify event, data
  end

  @doc """
  Notification for use in pipelines.

  Example:
  data
  |> process_data
  |> BusBar.notify_to :some_event
  """
  def notify_to(data, event) do
    BusBar.EventManager.notify event, data
  end

  @doc """
  Notify the bus of an event with data, and waituntil all handlers have
  processed the event.
  """
  def sync_notify(event, data) do
    BusBar.EventManager.sync_notify(event, data)
  end

  @doc false
  def start(_type, _args) do
    BusBar.Supervisor.start_link
  end
end
