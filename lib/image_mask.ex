defmodule ImageMask do
  def on() do
    path = "./masks/corey_mask_2.png"
    Mask.from_png(path)
    |> Grid.initialize()
    |> RecursiveBacktracker.on()
    |> Grid.to_png(5)
    |> ExPng.Image.to_file("./images/image_masked.png")
  end
end
