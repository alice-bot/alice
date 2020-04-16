defmodule AliceNew.Utilities do
  @moduledoc false
  @alice_version Mix.Project.config()[:version]

  def alice_version(), do: @alice_version

  def elixir_version(), do: elixir_version(System.version())

  def elixir_version(system_version) do
    {:ok, version} = Version.parse(system_version)

    "#{version.major}.#{version.minor}" <>
      case version.pre do
        [pre_release_identifier | _] -> "-#{pre_release_identifier}"
        [] -> ""
      end
  end

  def elixir_version_check!(), do: elixir_version_check!(System.version())

  def elixir_version_check!(system_version) do
    if Version.match?(system_version, "~> 1.7") do
      :ok
    else
      Mix.raise(
        "Alice v#{alice_version()} requires at least Elixir v1.7.\n " <>
          "You have #{system_version}. Please update accordingly"
      )
    end
  end

  def check_handler_name!(name, inferred?) do
    unless name =~ Regex.recompile!(~r/^[a-z][a-z0-9_]*$/) do
      inferred_message =
        if inferred? do
          ". The handler name is inferred from the path, if you'd like to " <>
            "explicitly name the handler then use the \"--handler NAME\" option"
        else
          ""
        end

      Mix.raise(
        "Handler name must start with a lowercase ASCII letter, followed by " <>
          "lowercase ASCII letters, numbers, or underscores, got: #{inspect(name)}" <>
          inferred_message
      )
    end

    if name |> String.trim() |> String.downcase() == "alice" do
      Mix.raise("Handler name cannot be alice")
    end
  end

  def check_mod_name_validity!(name) do
    unless name =~ Regex.recompile!(~r/^[A-Z]\w*(\.[A-Z]\w*)*$/) do
      Mix.raise(
        "Module name must be a valid Elixir alias (for example: MyHandler), got: #{inspect(name)}"
      )
    end
  end

  def handler_module(module_name) do
    "Alice.Handlers.#{module_name}"
  end

  def check_directory_existence!(path) do
    msg = "The directory #{inspect(path)} already exists. Are you sure you want to continue?"

    if File.dir?(path) and not Mix.shell().yes?(msg) do
      Mix.raise("Please select another directory for installation")
    end
  end
end
