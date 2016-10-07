defmodule Alice.ImagesTest do
  use ExUnit.Case, async: true

  test "does not provide a random tag for non-image urls" do
    potential_image = "http://example.com/example.txt"
    assert potential_image == Alice.Images.uncache(potential_image)
  end

  test "provides a random tag for non-image urls" do
    potential_image = "http://example.com/fancy_image.jpg"
    refute String.ends_with?(Alice.Images.uncache(potential_image), ["jpg"])
  end
end
