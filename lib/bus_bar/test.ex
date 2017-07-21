defmodule BusBar.Test do
  @moduledoc """
  BusBar.Test mimics BusBar but always sends synchronously.
  """

  use Application

  @doc """
  Attach a listener to the bus.
  """
  def attach(listener), do: BusBar.attach listener

  @doc """
  Detach a listener from the bus.
  """
  def detach(listener), do: BusBar.detach listener

  @doc """
  Returns a list of currently attached listeners.
  """
  def listeners(opts \\ []), do: BusBar.listeners(opts)

  @doc """
  Notify the bus of an event with data.
  """
  def notify(event, data), do: BusBar.sync_notify event, data

  @doc """
  Notification for use in pipelines.

  Example:
  data
  |> process_data
  |> BusBar.notify_to :some_event
  """
  def notify_to(data, event), do: BusBar.sync_notify event, data

  @doc """
  Notify the bus of an event with data, and wait until all handlers have
  processed the event
  """
  def sync_notify(event, data), do: BusBar.sync_notify(event, data)
end
