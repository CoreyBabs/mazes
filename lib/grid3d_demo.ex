defmodule Grid3dDemo do
  
  def demo() do
    Grid3d.initialize(3, 3, 3)
    |> RecursiveBacktracker.on()
    |> IO.inspect()
    |> Grid3d.to_png(20, 0)
    |> ExPng.Image.to_file("./images/grid3d.png")
  end
end
