defmodule BusBar.Supervisor do
  @moduledoc """
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    [
      worker(BusBar.Mains, []),
    ]
    |> supervise(strategy: :one_for_one)
  end

end
