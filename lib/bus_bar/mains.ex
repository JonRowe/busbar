defmodule BusBar.Mains do
  @moduledoc """
  The mains is responsible for connecting events.
  """

  def start_link do
    { :ok, pid } = GenEvent.start_link([])
    Agent.start_link(fn -> pid end, name: __MODULE__)
    { :ok, pid }
  end

end
