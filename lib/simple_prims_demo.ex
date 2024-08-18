defmodule SimplePrimsDemo do
  
  def demo() do
    grid = Grid.initialize(20, 20)
    start = Grid.random_cell(grid)
    SimplifiedPrims.on(grid, start)
    |> Grid.to_png(10)
    |> ExPng.Image.to_file("./images/simple_prims.png")
  end
end
