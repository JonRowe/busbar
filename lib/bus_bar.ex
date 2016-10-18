defmodule BusBar do
  @moduledoc """
  BusBar receives events and dispatches them to listeners via GenEvent.
  """

  use Application

  @doc """
  Attach a listener to the bus.
  """
  def attach(listener) do
    BusBar.Mains.attach listener
  end

  @doc """
  Detach a listener from the bus.
  """
  def detach(listener) do
    BusBar.Mains.detach listener
  end

  @doc """
  Returns a list of currently attached listeners.
  """
  def listeners do
    BusBar.Mains.listeners
  end

  @doc """
  Notify the bus of an event with data.
  """
  def notify(event, data) do
    BusBar.Mains.notify event, data
  end

  @doc """
  Notification for use in pipelines.

  Example:
  data
  |> process_data
  |> BusBar.notify_to :some_event
  """
  def notify_to(data, event) do
    BusBar.Mains.notify event, data
  end

  @doc """
  Wait until all handlers have processed event.
  """
  def sync(event) do
    BusBar.Mains.sync(event)
  end

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link(
      [
        worker(__MODULE__.Mains, [])
      ],
      [
        strategy: :one_for_one, name: BusBar.Supervisor
      ]
    )
  end
end
