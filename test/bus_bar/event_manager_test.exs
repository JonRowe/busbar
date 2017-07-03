defmodule BusBar.EventManagerTest do
  use ExUnit.Case
  doctest BusBar.EventManager

  alias BusBar.EventHandler
  alias BusBar.Supervisor, as: BusBarSuper

  defmodule TestHandler do
    require Logger

    def handle_event({event, {data, pid}}, parent) do
      send(pid, {event, data})
      { :ok, parent }
    end
  end

  defmodule ErrorTestHandler do
    def handle_event({:notify_test, {:error, _}}, _) do
      raise "boom"
    end
  end

  defmodule OtherTestHandler do
    def handle_event({event, {data, pid}}, parent) do
      send(pid, {:other, event, data})
      { :ok, parent }
    end
  end

  test "#attach will subscribe a handler to the bus" do
    :ok = BusBar.EventManager.attach TestHandler
    assert length(BusBarSuper.children) == 1
    :ok = BusBarSuper.remove TestHandler
  end

  test "#detach will remove a listener" do
    {:ok, _} = BusBarSuper.add EventHandler, [TestHandler], id: TestHandler
    BusBar.EventManager.detach TestHandler
    assert length(BusBarSuper.children) == 0
  end

  test "listeners will return all attached handlers" do
    {:ok, _} = BusBarSuper.add EventHandler, [TestHandler], id: TestHandler
    assert BusBar.EventManager.listeners == [TestHandler]
    :ok = BusBarSuper.remove TestHandler
  end

  test "listeners(with_pids: true) will return handlers with pids" do
    {:ok, pid} = BusBarSuper.add EventHandler, [TestHandler], id: TestHandler
    assert BusBar.EventManager.listeners(with_pids: true) ==
      [{TestHandler, pid}]
    :ok = BusBarSuper.remove TestHandler
  end

  test "#notify will call handle_event on all listeners" do
    {:ok, _} = BusBarSuper.add EventHandler, [TestHandler], id: :test
    {:ok, _} = BusBarSuper.add EventHandler, [OtherTestHandler], id: :other

    BusBar.EventManager.notify :notify_test, {1, self()}

    :ok = BusBarSuper.remove :test
    :ok = BusBarSuper.remove :other

    assert_received {:notify_test, 1}
    assert_received {:other, :notify_test, 1}
  end

  test "#notify will call handle_event on all listeners even if one errors" do
    {:ok, _} = BusBarSuper.add EventHandler, [TestHandler], id: :test
    {:ok, _} = BusBarSuper.add EventHandler, [ErrorTestHandler], id: :error
    {:ok, _} = BusBarSuper.add EventHandler, [OtherTestHandler], id: :other

    BusBar.EventManager.notify :notify_test, {:error, self()}

    :ok = BusBarSuper.remove :test
    :ok = BusBarSuper.remove :error
    :ok = BusBarSuper.remove :other

    assert_received {:notify_test, :error}
    assert_received {:other, :notify_test, :error}
  end

  test "#sync_notify will call handle_event on all listeners synchronously" do
    {:ok, _} = BusBarSuper.add EventHandler, [TestHandler], id: :test
    BusBar.EventManager.sync_notify :notify_test, {1, self()}
    :ok = BusBarSuper.remove :test

    assert_received {:notify_test, 1}
  end

  test "#sync_notify will call handle_event on listeners even if one errors" do
    {:ok, _} = BusBarSuper.add EventHandler, [TestHandler], id: :test
    {:ok, _} = BusBarSuper.add EventHandler, [ErrorTestHandler], id: :error
    {:ok, _} = BusBarSuper.add EventHandler, [OtherTestHandler], id: :other

    BusBar.EventManager.sync_notify :notify_test, {:error, self()}

    :ok = BusBarSuper.remove :test
    :ok = BusBarSuper.remove :error
    :ok = BusBarSuper.remove :other

    assert_received {:notify_test, :error}
    assert_received {:other, :notify_test, :error}
  end
end
