defmodule AliceNew.FileUtilitiesTest do
  use ExUnit.Case
  alias AliceNew.FileUtilities

  test "elixir_version_check! checks the system version" do
    assert :ok == FileUtilities.elixir_version_check!()
  end

  test "elixir_version_check! passes for 1.7" do
    assert :ok == FileUtilities.elixir_version_check!("1.7.0")
  end

  test "elixir_version_check! fails for 1.6" do
    error_message =
      "Alice v#{AliceNew.alice_version()} requires at least Elixir v1.7.\n " <>
        "You have 1.6.0. Please update accordingly"

    assert_raise Mix.Error, error_message, fn ->
      FileUtilities.elixir_version_check!("1.6.0")
    end
  end
end
