defmodule BusBar.Supervisor do
  @moduledoc """
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], [name: :bus_bar_supervisor])
  end

  def init(_) do
    [
      worker(BusBar.EventManager, []),
    ]
    |> supervise(strategy: :one_for_one)
  end

end
