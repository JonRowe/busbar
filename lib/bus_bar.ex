defmodule BusBar do
  @moduledoc """
  BusBar receives events and dispatches them to listeners via GenEvent.
  """

  use Application

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
