Code.ensure_compiled(Alice.Adapters.Test)

defmodule Alice.TestBot do
  use Alice.Bot, otp_app: :alice, adapter: Alice.Adapters.Test

  def handle_connect(%{name: name} = state) do
    if :undefined = :global.whereis_name(name) do
      :yes = :global.register_name(name, self())
    end

    {:ok, state}
  end

  def handle_disconnect(:error, state) do
    {:disconnect, :normal, state}
  end
  def handle_disconnect(:reconnect, state) do
    {:reconnect, state}
  end
  def handle_disconnect({:reconnect, timer}, state) do
    {:reconnect, timer, state}
  end

  def handle_in(%Alice.Message{} = msg, state) do
    {:dispatch, msg, state}
  end
  def handle_in({:ping, from}, state) do
    send(from, :pong)
    {:noreply, state}
  end
  def handle_in(msg, state) do
    super(msg, state)
  end
end
