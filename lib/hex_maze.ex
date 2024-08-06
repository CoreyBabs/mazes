defmodule HexMaze do
  def demo() do
    HexGrid.initialize(10, 10)
    |> RecursiveBacktracker.on()
    |> HexGrid.to_png()
    |> ExPng.Image.to_file("./images/hex_maze.png")
  end
end
