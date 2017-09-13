defmodule ProcessUtils do
  def register_eventually(pid, name) do
    case Process.whereis(name) do
      ^pid -> true
      nil  -> Process.register(pid, name)
      _    -> register_eventually(pid, make_name(name))
    end
  end

  def make_name(name) when is_atom(name) do
    "#{name}"
    |> String.split(".")
    |> Enum.reverse()
    |> make_name()
    |> String.to_atom()
  end
  def make_name(["Alt" <> num | rest]) do
    {num, _} = Integer.parse(num)
    ending = "Alt#{num+1}"
    Enum.join(Enum.reverse([ending | rest]), ".")
  end
  def make_name(name) when is_list(name) do
    Enum.join(Enum.reverse(["Alt1" | name]), ".")
  end
end
