defmodule AliceNew.MixHelper do
  @moduledoc """
  NOTE: Most of these helper functions were borrowed from the Phoenix installer
  """
  import ExUnit.Assertions

  def tmp_path do
    Path.expand("../tmp", __DIR__)
  end

  defp random_string(len) do
    len
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
    |> binary_part(0, len)
  end

  def in_tmp(which, function) do
    path = Path.join([tmp_path(), random_string(10), to_string(which)])

    try do
      File.rm_rf!(path)
      File.mkdir_p!(path)
      File.cd!(path, function)
    after
      File.rm_rf!(path)
    end
  end

  def refute_file(file) do
    refute File.regular?(file), "Expected #{file} to not exist, but it does"
  end

  def assert_file(file) do
    assert File.regular?(file), "Expected #{file} to exist, but does not"
  end

  def assert_file(file, matches) when is_list(matches) do
    assert_file(file, &Enum.each(matches, fn match -> assert &1 =~ match end))
  end

  def assert_file(file, match) when is_binary(match) do
    assert_file(file, &assert(&1 =~ match))
  end

  def assert_file(file, assertion) when is_function(assertion, 1) do
    assert_file(file)
    assertion.(File.read!(file))
  end

  def assert_file(file, match) do
    raise inspect({file, match})
  end
end
