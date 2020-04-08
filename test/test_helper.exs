defmodule Alice.TestHelpers do
  def conn do
    %Alice.Conn{message: %{channel: :channel}, slack: :slack}
  end
end

ExUnit.start()
Application.ensure_all_started(:mox)
