defmodule BusBarTest do
  use ExUnit.Case
  doctest BusBar

  import ExUnit.CaptureLog

  defmodule TestHandler do
    require Logger

    def handle_event({:notify_test, _}, state) do
      Logger.info "Notify api test success"
      {:ok, state}
    end

    def handle_event({:produce_consume_test, event}, state) do
      BusBar.notify event, "this"
      Logger.info "Produce consume success"
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
    log = capture_log(fn ->
      BusBar.notify :notify_test, [:some, :data]
    end)
    assert log =~ ~r/Notify api test success/
  end

  test "#notify_to" do
    log = capture_log(fn ->
      [:some, :data] |> BusBar.notify_to(:notify_test)
    end)
    assert log =~ ~r/Notify api test success/
  end

  test "#notify doesn't block when nested" do
    BusBar.notify :produce_consume_test, :notify_test
    BusBar.notify :produce_consume_test, :not_notify_test
  end

  test "#notify doesn't block when no matching event" do
    BusBar.notify :not_notify_test, [:some, :data]
  end

  test "#sync_notify doesn't block when no matching event" do
    BusBar.sync_notify :not_notify_test, [:some, :data]
  end

  test "#listeners" do
    assert BusBar.listeners, [TestHandler]
  end
end
