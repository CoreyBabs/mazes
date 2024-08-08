defmodule DeltaMaze do
  def demo() do
    TriangleGrid.initialize(10, 17)
    |> RecursiveBacktracker.on()
    |> TriangleGrid.to_png()
    |> ExPng.Image.to_file("./images/delta_maze.png")
  end
end
