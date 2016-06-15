defmodule FakeAdapter do
  def start_link, do: send(self, :started)
end

defmodule Alice.AdaptersTest do
  use ExUnit.Case

  setup do
    adapter = Application.get_env(:alice, :adapter)
    Application.put_env(:alice, :adapter, FakeAdapter)
    on_exit(fn -> Application.put_env(:alice, :adapter, adapter) end)
    :ok
  end

  test "start_link starts the adapter" do
    Alice.Adapters.start_link
    assert_received :started
  end

  test "start_link does not start the adapter when start_adapter is false" do
    Alice.Adapters.start_link(start_adapter: false)
    refute_received :started
  end

  test "start_link returns the selected adapter" do
    assert {:ok, FakeAdapter} == Alice.Adapters.start_link
  end

  test "selected_adapter returns the configured adapter" do
    assert FakeAdapter == Alice.Adapters.selected_adapter
  end

  test "selected_adapter defaults to slack" do
    Application.delete_env(:alice, :adapter)
    assert Alice.Adapters.Slack == Alice.Adapters.selected_adapter
  end
end
