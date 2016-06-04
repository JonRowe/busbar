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
  end

  test "#notify" do
    log = capture_log(fn ->
      BusBar.notify :notify_test, [:some, :data]
      BusBar.sync :notify_test
    end)
    assert log =~ ~r/Notify api test success/
  end

  test "#notify_to" do
    log = capture_log(fn ->
      [:some, :data] |> BusBar.notify_to(:notify_test)
      BusBar.sync :notify_test
    end)
    assert log =~ ~r/Notify api test success/
  end
end
