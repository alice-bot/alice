defmodule Alice.Bot.ConfigTest do
  use ExUnit.Case

  alias Alice.Bot.Config

  test "get_bot_config when missing otp config" do
    config = [log_level: :debug, bot_module: Unconfigured.Bot, otp_app: :unconfigured]
    assert config == Config.get_bot_config(Unconfigured.Bot, :unconfigured, [])
  end

  test "get_bot_config! when missing otp config" do
    assert_raise ArgumentError, fn ->
      Config.get_bot_config!(Unconfigured.Bot, :unconfigured, [])
    end
  end

  describe "init_config" do
    test "when config is good" do
      opts = [otp_app: :alice, adapter: Alice.Adapters.Console]
      result = Config.init_config(Alice.Bot, opts)
      bot_config = [log_level: :debug, bot_module: Alice.Bot, otp_app: :alice, adapter: Alice.Adapters.Console]
      assert result == Config.new(:alice, Alice.Adapters.Console, bot_config)
    end

    test "when missing adapter keyword" do
      opts = [otp_app: :alice]
      assert_raise ArgumentError, fn ->
        Config.init_config(Alice.Bot, opts)
      end
    end
  end
end
