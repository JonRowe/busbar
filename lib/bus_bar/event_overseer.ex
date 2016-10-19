defmodule BusBar.EventOverseer do
  @moduledoc """
  The EventOverseer is a supervisor for the EventWatchers.
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], [name: :bus_bar_overseer])
  end

  def init(_) do
    [
      worker(BusBar.EventWatcher, [], restart: :transient)
    ]
    |> supervise(strategy: :simple_one_for_one)
  end

  def monitor(handler) do
    { :ok, _child } = Supervisor.start_child(:bus_bar_overseer, [handler])
    :ok
  end

end
