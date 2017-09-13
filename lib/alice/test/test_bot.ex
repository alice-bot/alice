Code.ensure_compiled(Alice.Adapters.Test)

defmodule Alice.TestBot do
  use Alice.Bot, otp_app: :alice

  def handle_connect(bot) do
    true = ProcessUtils.register_eventually(self(), Alice.TestBot)
    {:ok, bot}
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
