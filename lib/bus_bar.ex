defmodule BusBar do
  @moduledoc """
  BusBar receives events and dispatches them to listeners via GenEvent.
  """

  use Application

  @doc """
  Attach a listener to the bus.
  """
  def attach(listener, args \\ []) do
    BusBar.Mains.attach listener, args
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
