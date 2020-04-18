defmodule Alice.ChatBackends.OutboundClient do
  @moduledoc """
  Documentation for the OutboundClient behavior. This defines a behavior for
  modules that serve as an outbound connection to a backend.
  """

  @callback send_message(
              message :: String.t(),
              channel :: String.t(),
              service_state :: map()
            ) :: :ok | {:error, error_message :: String.t()}

  @callback indicate_typing(
              channel :: String.t(),
              service_state :: map()
            ) :: :ok | {:error, error_message :: String.t()}
end
