defmodule BusBar.Supervisor do
  @moduledoc """
  Convenience handler for talking to the busbar supervisor.
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: :bus_bar_supervisor)
  end

  def init(_) do
    supervise([], strategy: :one_for_one)
  end

  def children do
    Supervisor.which_children(:bus_bar_supervisor)
  end

  def add(child, args \\ [], opts \\ []) do
    import Supervisor.Spec

    Supervisor.start_child(:bus_bar_supervisor, worker(child, args, opts))
  end

  def remove(child) do
    :ok = Supervisor.terminate_child(:bus_bar_supervisor, child)
    :ok = Supervisor.delete_child(:bus_bar_supervisor, child)
  end
end
