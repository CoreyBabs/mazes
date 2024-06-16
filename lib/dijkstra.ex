defmodule Dijkstra do
  def solve() do
    grid = Grid.initialize(6, 6)
    |> Sidewinder.on()

    start = Grid.get_cell(grid, 0, 0)
    distances = Grid.distances_from_cell(grid, start)

    Grid.to_string(grid, distances)
    |> IO.puts()
  end
end
