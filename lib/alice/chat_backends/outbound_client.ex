defmodule Alice.ChatBackends.OutboundClient do
  @moduledoc """
    Documentation for the OutboundClient behavior. This defines a behavior for modules that serve as an outbound connection to a backend.
  """

  @callback send_message(response :: String.t(), channel :: String.t(), backend :: map()) :: String.t()
  @callback indicate_typing(channel :: String.t(), backend :: map()) :: String.t()
end
