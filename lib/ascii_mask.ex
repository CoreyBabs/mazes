defmodule AsciiMask do
  def on() do
    path = "./masks/basic_mask.txt"
    Mask.from_txt(path)
    |> Grid.initialize()
    |> RecursiveBacktracker.on()
    |> Grid.to_png(10)
    |> ExPng.Image.to_file("./images/masked.png")
  end
end
