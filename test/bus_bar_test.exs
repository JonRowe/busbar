defmodule BusBarTest do
  use ExUnit.Case
  doctest BusBar

  defmodule TestHandler do
    def handle_event({:produce_consume_test, {event, pid}}, state) do
      BusBar.notify event, pid
      {:ok, state}
    end

    def handle_event({:notify_test, pid}, state) do
      send(pid, :notify_test)
      {:ok, state}
    end

    def handle_event({:long_notify_test, pid}, state) do
      Process.sleep 200
      send(pid, :long_notify_test)
      {:ok, state}
    end

    def handle_event({:sync_notify_test, pid}, state) do
      send(pid, :sync_notify_test)
      {:ok, state}
    end
  end

  setup do
    BusBar.attach TestHandler
    on_exit fn ->
      BusBar.detach TestHandler
    end
  end

  test "#notify" do
    BusBar.notify :notify_test, self()
    assert_receive :notify_test
  end

  test "#notify_to" do
    self() |> BusBar.notify_to(:notify_test)
    assert_receive :notify_test
  end

  test "#notify doesn't block when nested" do
    BusBar.notify :produce_consume_test, {:notify_test, self()}
    BusBar.notify :produce_consume_test, {:not_notify_test, self()}
    assert_receive :notify_test
  end

  test "#notify doesn't block when no matching event" do
    BusBar.notify :not_notify_test, self()
    refute_received :not_notify_test
  end

  test "#sync_notify doesn't block when no matching event" do
    BusBar.sync_notify :not_notify_test, self()
    refute_received :not_notify_test
  end

  test "#sync_notify blocks until sync finished" do
    BusBar.notify :long_notify_test, self()
    BusBar.sync_notify :sync_notify_test, self()

    first = receive do
      message -> message
    end
    second = receive do
      message -> message
    end
    assert [first, second] == [:long_notify_test, :sync_notify_test]
  end

  test "#listeners" do
    assert BusBar.listeners, [TestHandler]
  end
end
