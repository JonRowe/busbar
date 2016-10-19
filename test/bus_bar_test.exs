defmodule BusBarTest do
  use ExUnit.Case
  doctest BusBar

  import ExUnit.CaptureLog

  defmodule TestHandler do
    use GenEvent
    require Logger

    def handle_event({:notify_test, _ }, parent) do
      Logger.info "Notify api test success"
      { :ok, parent }
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

  test "#listeners" do
    assert BusBar.listeners, [TestHandler]
  end
end
