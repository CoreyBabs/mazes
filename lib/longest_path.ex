defmodule LongestPath do
  def solve() do
    grid = Grid.initialize(6, 6)
    |> BinaryTree.on()

    start = Grid.get_cell(grid, 0, 0)
    distances = Grid.distances_from_cell(grid, start)
    {new_start, _distance} = Distances.max(distances)

    new_start = Grid.get_cell(grid, new_start)
    distances = Grid.distances_from_cell(grid, new_start)
    {goal, _distance} = Distances.max(distances)
    goal = Grid.get_cell(grid, goal)
    path = Distances.path_to(grid, distances, goal)

    Grid.to_string(grid, distances)
    |> IO.puts()

    Grid.to_string(grid, path)
    |> IO.puts()
  end
end
