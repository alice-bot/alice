defmodule Alice.Images do
  def uncache(potential_image) do
    ~w[gif png jpg jpeg]
    |> Enum.any?(&(potential_image |> String.downcase |> String.ends_with?(&1)))
    |> case do
      true -> "#{potential_image}##{random_tag()}"
      _    -> potential_image
    end
  end

  defp random_tag do
    "0." <> tag = to_string(:rand.uniform)
    tag
  end
end
