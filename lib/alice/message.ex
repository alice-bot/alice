defmodule Alice.Message do
  @moduledoc "Alice message"

  @type captures :: list | map
  @type private  :: map
  @type ref      :: reference
  @type bot      :: pid
  @type room     :: binary
  @type text     :: binary
  @type type     :: binary
  @type user     :: Alice.User.t

  @type t :: %__MODULE__{
    captures: captures,
    private:  private,
    ref:      ref,
    bot:      bot,
    room:     room,
    text:     text,
    type:     type,
    user:     user
  }

  defstruct captures: nil,
            private:  %{},
            ref:      nil,
            bot:      nil,
            room:     nil,
            text:     nil,
            type:     nil,
            user:     %Alice.User{}
end
