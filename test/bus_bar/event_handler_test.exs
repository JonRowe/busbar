defmodule BusBar.EventHandlerTest do
  use ExUnit.Case
  doctest BusBar.EventHandler

  alias BusBar.EventHandler
  alias BusBar.Supervisor

  defmodule TestHandler do
    def handle_event({event, pid}, _) do
      send(pid, {:test_event, event})
    end
  end

  test "it can be added and removed to a supervisor" do
    {:ok, pid} = Supervisor.add EventHandler, [TestHandler]

    assert Supervisor.children == [
      {EventHandler, pid, :worker, [EventHandler]}
    ]

    Supervisor.remove EventHandler
    assert Supervisor.children == []
  end

  test "it wraps a handler which responds to handle_event as handle_cast" do
    {:ok, pid} = EventHandler.start_link TestHandler
    GenServer.cast pid, {:cast, self()}
    GenServer.stop pid

    assert_received {:test_event, :cast}
  end

  test "it wraps a handler which responds to handle_event as handle_call" do
    {:ok, pid} = EventHandler.start_link TestHandler
    GenServer.call pid, {:call, self()}
    GenServer.stop pid

    assert_received {:test_event, :call}
  end
end
