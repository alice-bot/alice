Code.require_file("mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Alice.New.HandlerTest do
  use ExUnit.Case, async: false

  import AliceNew.MixHelper
  import ExUnit.CaptureIO
  alias Mix.Tasks.Alice.New.Handler

  @handler_name "super_awesome"
  @app_name "alice_#{@handler_name}"
  @module_name "SuperAwesome"
  @alice_version "0.4.3"

  test "alice.new.handler with defaults" do
    in_tmp("new handler with defaults", fn ->
      output =
        capture_io(fn ->
          Handler.run([@handler_name])

          assert_file("#{@app_name}/README.md", fn file ->
            assert file =~ "AliceSuperAwesome"
            assert file =~ ~s({:alice, "~> #{@alice_version}"})
          end)

          assert_file("#{@app_name}/.formatter.exs", fn file ->
            assert file =~ "import_deps: [:alice]"
          end)

          assert_file("#{@app_name}/.gitignore")

          assert_file("#{@app_name}/config/config.exs")

          assert_file("#{@app_name}/lib/alice/handlers/#{@handler_name}.ex", fn file ->
            assert file =~ "defmodule Alice.Handlers.#{@module_name} do"
            assert file =~ "use Alice.Router"
          end)

          assert_file("#{@app_name}/mix.exs", fn file ->
            assert file =~ "defmodule Alice#{@module_name}.MixProject do"
            assert file =~ "app: :#{@app_name}"
            assert file =~ ~s({:ex_doc, ">= 0.0.0", only: :dev, runtime: false})
            assert file =~ ~s({:alice, "~> #{@alice_version}"})
          end)

          assert_file("#{@app_name}/test/test_helper.exs")

          assert_file("#{@app_name}/test/alice/handlers/#{@handler_name}_test.exs", fn file ->
            assert file =~ "defmodule Alice.Handlers.#{@module_name}Test do"
            assert file =~ "use Alice.HandlerCase, handlers: Alice.Handlers.SuperAwesome"
            assert file =~ "send_message"
            assert file =~ "first_reply"
          end)
        end)

      assert output =~ "Your Alice handler was created successfully."
    end)
  end

  test "alice.new.handler with invlid flags" do
    assert_raise Mix.Error, ~r"Invalid option: --invlid", fn ->
      Handler.run(["valid", "--invlid", "bogus"])
    end
  end

  test "alice.new.handler with invalid args" do
    in_tmp("check invalid args", fn ->
      assert_raise Mix.Error, ~r"Handler name cannot be alice", fn ->
        Handler.run(["alice"])
      end

      assert_raise Mix.Error, ~r"Handler name cannot be alice", fn ->
        Handler.run(["folder/alice"])
      end

      assert_raise Mix.Error, ~r"Handler name must start with a lowercase ASCII letter,", fn ->
        Handler.run(["93invalid"])
      end

      assert_raise Mix.Error, ~r"Handler name must start with a lowercase ASCII letter, ", fn ->
        Handler.run(["valid", "--name", "93invalid"])
      end

      assert_raise Mix.Error, ~r"Module name must be a valid Elixir alias", fn ->
        Handler.run(["valid", "--module", "not.valid"])
      end
    end)
  end

  test "alice.new.handler with version" do
    output = capture_io(fn -> Handler.run(["-v"]) end)
    assert output =~ "Alice v#{@alice_version}"

    output = capture_io(fn -> Handler.run(["--version"]) end)
    assert output =~ "Alice v#{@alice_version}"
  end

  test "alice.new.handler without args" do
    output = capture_io(fn -> Handler.run([]) end)
    assert output =~ "Generates a new Alice handler."
  end

  test "alice.new.handler check for directory existence" do
    shell = Mix.shell()

    in_tmp("check for directory existence", fn ->
      File.mkdir!(@app_name)

      # Send Mix messages to the current process instead of performing IO
      Mix.shell(Mix.Shell.Process)
      msg = ~s(The directory "#{@app_name}" already exists. Are you sure you want to continue?)

      assert_raise Mix.Error, ~r"Please select another directory for installation", fn ->
        # The shell ask if we want to continue. We will say no.
        send(self(), {:mix_shell_input, :yes?, false})
        Handler.run([@handler_name])
        assert_received {:mix_shell, :yes?, [^msg]}
      end
    end)

    Mix.shell(shell)
  end
end
