defmodule Alice.Images do
  @moduledoc """
  Generates a random tag on images so that they aren't cached and always show up in replies.
  """
  def uncache(potential_image) do
    ~w[gif png jpg jpeg]
    |> Enum.any?(&(potential_image |> String.downcase() |> String.ends_with?(&1)))
    |> case do
      true -> "#{potential_image}##{random_tag()}"
      _ -> potential_image
    end
  end

  defp random_tag do
    "0." <> tag = to_string(:rand.uniform())
    tag
  end
end
