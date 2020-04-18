defmodule AliceNewTest do
  use ExUnit.Case

  test "elixir_version matches the system version" do
    assert System.version() =~ AliceNew.elixir_version()
  end

  test "elixir_version returns the major and minor parts only" do
    assert AliceNew.elixir_version("1.7.5") == "1.7"
  end

  test "elixir_version returns the pre-release-identifier if given a pre-release" do
    assert AliceNew.elixir_version("1.8.0-rc.1") == "1.8-rc"
  end
end
