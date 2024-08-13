defmodule WeightedMaze do
  def demo() do
    grid = Grid.initialize(10, 10)
    |> RecursiveBacktracker.on()
    |> Grid.braid(0.5)

    IO.puts("grid is braided")
    start = Grid.get_cell(grid, {0, 0})
    finish = Grid.get_cell(grid, {grid.rows - 1, grid.cols - 1})

    distances = Grid.weights_from_cell(grid, start)
    IO.puts("weigths calculated")
    distances = Distances.path_to(grid, distances, finish)
    IO.puts("path found")

    {_f, max} = Distances.max(distances)
    Grid.to_png_with_color(grid, 1, distances, max, true)
    |> ExPng.Image.to_file("./images/original.png")

    lava = Distances.cells(distances) |> Enum.random()
    grid = Grid.get_cell(grid, lava)
    |> Cell.add_weight(50)
    |> Grid.update_grid_with_cell(grid)

    distances = Grid.weights_from_cell(grid, start)
    IO.puts("weigths calculated")
    distances = Distances.path_to(grid, distances, finish)
    IO.puts("path found")

    {_f, max} = Distances.max(distances)
    IO.puts("Lava added")

    Grid.to_png_with_color(grid, 1, distances, max, true)
    |> ExPng.Image.to_file("./images/rerouted.png")
  end
end
