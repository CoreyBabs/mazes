defmodule PrimsDemo do
  
  def demo() do
    grid = Grid.initialize(20, 20)
    start = Grid.random_cell(grid)
    Prims.on(grid, start)
    |> Grid.to_png(10)
    |> ExPng.Image.to_file("./images/prims.png")
  end
end
