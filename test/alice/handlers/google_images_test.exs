defmodule FakeHTTPoison do
  def get(url, headers \\ [], opts \\ []) do
    return = {:ok, %HTTPoison.Response{status_code: 200}}
    Mock.setup({FakeHTTPoison, :get}, {url, headers, opts}, default_return: return)
  end
end

defmodule Alice.Handlers.GoogleImagesTest do
  use ExUnit.Case, async: true
  alias Alice.Handlers.GoogleImages, as: GI

  setup do
    Logger.disable(self)
    :ok
  end

  def conn_with_text(text) do
    Alice.Conn.make(%{text: text}, %{})
  end

  def response(body) do
    %HTTPoison.Response{status_code: 200, body: body}
  end

  test "extract_term gets the term" do
    {pattern, :fetch} = hd(GI.routes)
    conn = conn_with_text("img me stuff")
           |> Alice.Conn.add_captures(pattern)
    assert GI.extract_term(conn) == "stuff"
  end

  test "get_images returns the response" do
    Mock.setup_return({FakeHTTPoison, :get}, {:ok, response(:body)})
    assert {:ok, :body} = GI.get_images("stuff", FakeHTTPoison)
  end

  test "get_images returns an error when there is an error" do
    Mock.setup_return({FakeHTTPoison, :get}, {:error, %HTTPoison.Error{reason: :reason}})
    assert {:error, :reason} = GI.get_images("stuff", FakeHTTPoison)
  end

  test "get_images calls HTTPoison get with the correct options" do
    url = "https://www.googleapis.com/customsearch/v1"
    GI.get_images("stuff", FakeHTTPoison)

    assert_received {{FakeHTTPoison, :get}, {^url, _headers, opts}}
    assert "stuff" = opts[:params][:q]
  end
end
