defmodule AliceNew.UtilitiesTest do
  use ExUnit.Case
  alias AliceNew.Utilities

  test "elixir_version matches the system version" do
    assert System.version() =~ Utilities.elixir_version()
  end

  test "elixir_version returns the major and minor parts only" do
    assert Utilities.elixir_version("1.7.5") == "1.7"
  end

  test "elixir_version returns the pre-release-identifier if given a pre-release" do
    assert Utilities.elixir_version("1.8.0-rc.1") == "1.8-rc"
  end

  test "elixir_version_check! checks the system version" do
    assert :ok == Utilities.elixir_version_check!()
  end

  test "elixir_version_check! passes for 1.7" do
    assert :ok == Utilities.elixir_version_check!("1.7.0")
  end

  test "elixir_version_check! fails for 1.6" do
    error_message =
      "Alice v#{Utilities.alice_version()} requires at least Elixir v1.7.\n " <>
        "You have 1.6.0. Please update accordingly"

    assert_raise Mix.Error, error_message, fn ->
      Utilities.elixir_version_check!("1.6.0")
    end
  end
end
