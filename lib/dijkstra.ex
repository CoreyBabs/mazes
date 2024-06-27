defmodule Dijkstra do
  def solve() do
    grid = Grid.initialize(6, 6)
    |> Sidewinder.on()

    start = Grid.get_cell(grid, 0, 0)
    distances = Grid.distances_from_cell(grid, start)
    path = Distances.path_to(grid, distances, Grid.get_cell(grid, grid.rows - 1, 0))

    Grid.to_string(grid, distances)
    |> IO.puts()

    Grid.to_string(grid, path)
    |> IO.puts()
  end

  def solve_with_image() do
    grid = Grid.initialize(25, 25)
    |> Sidewinder.on()

    start = Grid.get_cell(grid, 0, 0)
    distances = Grid.distances_from_cell(grid, start)
    path = Distances.path_to(grid, distances, Grid.get_cell(grid, grid.rows - 1, 0))

    Grid.to_png_with_color(grid, 1, path, 0)
    |> ExPng.Image.to_file("./images/solution.png")
  end
end
