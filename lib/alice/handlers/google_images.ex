defmodule Alice.Handlers.GoogleImages do
  use Alice.Router

  @url "https://www.googleapis.com/customsearch/v1"

  def cse_id,     do: Application.get_env(:alice, :google_images_cse_id)
  def cse_token,  do: Application.get_env(:alice, :google_images_cse_token)
  def safe_value do
    case Application.get_env(:alice, :google_images_safe_search_level) do
      level when level in [:high, :medium, :off] -> level
      _ -> :high
    end
  end

  route ~r/(image|img)(\s+me)? (?<term>.+)/i, :fetch
  command ~r/(image|img)(\s+me)? (?<term>.+)/i, :fetch

  def handle(conn, :fetch) do
    conn
    |> extract_term
    |> get_images
    |> select_image
    |> reply(conn)
  end

  def extract_term(conn) do
    conn.message.captures
    |> Enum.reverse
    |> hd
  end

  def get_images(term, http \\ HTTPoison) do
    case http.get(@url, [], params: query_params(term)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}
      {:ok, response} ->
        Logger.warn("Google Images: Something went wrong")
        IO.inspect response
        IO.inspect query_params(term)
        {:error, nil}
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.warn("Couldn't get image from Google: #{reason}")
        {:error, reason}
    end
  end

  def query_params(term) do
    [ v: "1.0",
      searchType: "image",
      q: term,
      safe: safe_value,
      fields: "items(link)",
      rsz: 8,
      cx: cse_id,
      key: cse_token ]
  end
  end

  defp select_image({:error, reason}), do: "Error: #{reason}"
  defp select_image({:ok, body}) do
    body
    |> Poison.decode!
    |> Map.get("items", [%{}])
    |> Enum.random
    |> Map.get("link", "No images found")
  end
end
