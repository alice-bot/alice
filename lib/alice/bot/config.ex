defmodule Alice.Bot.Config do
  defstruct [:otp_app, :adapter, :bot_config]

  def new(otp_app, adapter, bot_config) do
    %__MODULE__{otp_app: otp_app, adapter: adapter, bot_config: bot_config}
  end

  def init_config(bot_module, opts_from_use) do
    otp_app = opts_from_use[:otp_app]
    bot_config = get_bot_config(bot_module, otp_app, opts_from_use)
    adapter = ensure_adapter!(opts_from_use, bot_config)
    new(otp_app, adapter, bot_config)
  end

  def get_bot_config(bot_module, otp_app, opts_from_use) do
    otp_app
    |> Application.get_env(bot_module, [])
    |> configure_bot(bot_module, otp_app, opts_from_use)
  end

  def get_bot_config!(bot_module, otp_app, opts_from_use) do
    if bot_config = Application.get_env(otp_app, bot_module) do
      configure_bot(bot_config, bot_module, otp_app, opts_from_use)
    else
      raise ArgumentError, "No config found. Please configure your bot."
    end
  end

  defp configure_bot(bot_config, bot_module, otp_app, opts_from_use) do
    bot_config
    |> Keyword.put(:otp_app, otp_app)
    |> Keyword.put(:bot_module, bot_module)
    |> Keyword.put_new(:log_level, :debug)
    |> Keyword.merge(opts_from_use)
  end

  defp ensure_adapter!(opts, config) do
    adapter = opts[:adapter] || config[:adapter] || :no_adapter
    ensure_adapter!(adapter)
  end
  defp ensure_adapter!(:no_adapter), do: raise ArgumentError, "please configure an adapter"
  defp ensure_adapter!(adapter), do: adapter
end
