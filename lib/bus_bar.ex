defmodule BusBar do
  @moduledoc """
  BusBar receives events and dispatches them to listeners via GenEvent.
  """

  use Application

  def attach(listener, args \\ []) do
    BusBar.Mains.attach listener, args
  end

  def notify(event, data) do
    BusBar.Mains.notify event, data
  end

  def notify_to(data, event) do
    BusBar.Mains.notify event, data
  end

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
