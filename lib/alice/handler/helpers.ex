defmodule Alice.Handler.Helpers do
  alias Alice.Message, as: Msg

  @doc """
  Reply to a message in a handler.

  Takes a conn and a response string in any order.
  Sends `response` back to the channel that triggered the handler.

  Adds random tag to end of image urls to break Slack's img cache.
  """
  def reply(resp, %Msg{} = msg), do: reply(msg, resp)
  def reply(%Msg{} = msg, resp) when is_list(resp) do
    random_reply(msg, resp)
  end
  def reply(%Msg{bot: bot} = msg, resp) do
    Alice.Bot.reply(bot, %{msg | text: uncache_images(resp)})
  end

  @doc """
  Takes a mag and a list of possible responses in any order.
  Replies with a random element of the `list` provided.
  """
  def random_reply(%Msg{} = msg, list), do: random_reply(list, msg)
  def random_reply(list, %Msg{} = msg) do
    list
    |> random
    |> reply(msg)
  end

  @doc """
  Reply with random chance.

  Examples

      chance_reply(msg, 0.5, "sent half the time")
      chance_reply(msg, 0.25, "sent 25% of the time", "sent 75% of the time")
  """
  def chance_reply(%Msg{} = msg, chance, positive, negative \\ :noreply) do
    {:rand.uniform <= chance, negative}
    |> do_chance_reply(positive, msg)
  end

  @doc """
  Delay a reply. Alice will show to be typing while the text is delayed.
  (JK, indicate typing is not implemented yet)

  The msg can be passed in first or last.

  Returns the task, not a msg. If you need to get the msg, you can
  use `Task.await(task)`, but this will block the handler process
  until the delay finishes. If you don't need the updated msg,
  simply return the msg that was passed to delayed_reply.

  Examples

      def hello(msg, _state) do
        delayed_reply("hello from the past", 1000, msg)
        reply("hello from now", msg)
      end

      def hello(msg) do
        task = delayed_reply(msg, "hello", 1000)
        # other work...
        Task.await(task)
      end
  """
  def delayed_reply(text, ms, msg = %Msg{}), do: delayed_reply(msg, text, ms)
  def delayed_reply(msg = %Msg{}, text, milliseconds) do
    Task.async(fn ->
      # msg = indicate_typing(msg)
      :timer.sleep(milliseconds)
      reply(text, msg)
    end)
  end

  def random(list) do
    Enum.random(list)
  end

  defp uncache_images(potential_image) do
    ~w[gif png jpg jpeg]
    |> Enum.any?(&(potential_image |> String.downcase |> String.ends_with?(&1)))
    |> case do
      true -> "#{potential_image}##{unique_tag()}"
      _    -> potential_image
    end
  end

  defp unique_tag do
    System.unique_integer([:positive, :monotonic])
  end

  defp do_chance_reply({true, _}, resp, msg), do: reply(msg, resp)
  defp do_chance_reply({false, :noreply}, _, msg), do: msg
  defp do_chance_reply({false, resp}, _, msg), do: reply(msg, resp)

  #TODO: implement indicate typing
  # defp indicate_typing(%Msg{bot: bot} = msg) do
  #   Alice.Bot.indicate_typing(bot)
  #   msg
  # end
end
