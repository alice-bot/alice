defmodule AliceNew.HandlerGenerator do
  @moduledoc false
  import Mix.Generator
  alias AliceNew.Utilities

  templates = [
    formatter: "templates/formatter.exs",
    gitignore: "templates/gitignore.eex",
    readme: "templates/new_handler/README.md.eex",
    mix_exs: "templates/new_handler/mix.exs.eex",
    config: "templates/new_handler/config/config.exs.eex",
    handler: "templates/new_handler/lib/alice/handlers/handler.ex.eex",
    handler_test: "templates/new_handler/test/alice/handlers/handler_test.exs.eex"
  ]

  Enum.each(templates, fn {name, file} ->
    Mix.Generator.embed_template(name, from_file: file)
  end)

  def generate(app_name, handler_name, handler_module, path) do
    assigns = [
      app_name: app_name,
      handler_name: handler_name,
      handler_module: handler_module,
      elixir_version: Utilities.elixir_version(),
      alice_version: Utilities.alice_version()
    ]

    create_file(".formatter.exs", formatter_template(assigns))
    create_file(".gitignore", gitignore_template(assigns))
    create_file("README.md", readme_template(assigns))
    create_file("mix.exs", mix_exs_template(assigns))

    create_directory("config")
    create_file("config/config.exs", config_template(assigns))

    create_directory("lib/alice/handlers")
    create_file("lib/alice/handlers/#{handler_name}.ex", handler_template(assigns))

    create_directory("test/alice/handlers")
    create_file("test/test_helper.exs", "ExUnit.start()\n")
    create_file("test/alice/handlers/#{handler_name}_test.exs", handler_test_template(assigns))

    """

    Your Alice handler was created successfully.

    Next steps for getting started:

        $ cd #{path}
        $ mix deps.get

    Your handler code is in lib/alice/handlers/#{handler_name}.ex
    Your handler test is at test/alice/handlers/#{handler_name}_test.ex
    """
    |> Mix.shell().info()
  end
end
