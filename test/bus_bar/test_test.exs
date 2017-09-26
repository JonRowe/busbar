defmodule BusBar.TestTest do
  use ExUnit.Case
  doctest BusBar.Test

  defmodule TestHandler do
    def handle_event({:notify_test, pid}, state) do
      send(pid, :notify_test)
      {:ok, state}
    end

    def handle_event({:long_notify_test, pid}, state) do
      sleep 200
      send(pid, :long_notify_test)
      {:ok, state}
    end

    def handle_event({:sync_notify_test, pid}, state) do
      send(pid, :sync_notify_test)
      {:ok, state}
    end

    def sleep(timeout)
      when is_integer(timeout) and timeout >= 0
      when timeout == :infinity do
        receive after: (timeout -> :ok)
    end
  end

  defmodule OtherTestHandler do
    def handle_event({:produce_consume_test, {event, pid}}, state) do
      BusBar.Test.notify event, pid
      {:ok, state}
    end
  end


  setup do
    BusBar.Test.attach TestHandler
    BusBar.Test.attach OtherTestHandler
    on_exit fn ->
      BusBar.Test.detach TestHandler
      BusBar.Test.detach OtherTestHandler
    end
  end

  test "#notify" do
    BusBar.Test.notify :notify_test, self()
    assert_receive :notify_test
  end

  test "#notify_to" do
    self() |> BusBar.Test.notify_to(:notify_test)
    assert_receive :notify_test
  end

  test "#notify doesn't block when nested" do
    BusBar.Test.notify :produce_consume_test, {:notify_test, self()}
    BusBar.Test.notify :produce_consume_test, {:not_notify_test, self()}
    assert_receive :notify_test
  end

  test "#notify doesn't block when no matching event" do
    BusBar.Test.notify :not_notify_test, self()
    refute_received :not_notify_test
  end

  test "#sync_notify doesn't block when no matching event" do
    BusBar.Test.sync_notify :not_notify_test, self()
    refute_received :not_notify_test
  end

  test "#sync_notify blocks until sync finished" do
    BusBar.Test.notify :long_notify_test, self()
    BusBar.Test.sync_notify :sync_notify_test, self()

    first = receive do
      message -> message
    end
    second = receive do
      message -> message
    end
    assert [first, second] == [:long_notify_test, :sync_notify_test]
  end

  test "#listeners" do
    assert BusBar.Test.listeners, [TestHandler]
  end
end
