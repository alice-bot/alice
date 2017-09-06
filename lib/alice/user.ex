defmodule Alice.User do
  @moduledoc "Alice user"

  @type user_id  :: binary
  @type username :: binary

  @type t :: %__MODULE__{
    id:   user_id,
    name: username
  }

  defstruct id: nil, name: nil
end
