defmodule Distances do
  defstruct [:root, :cells]

  def initialize(root) when is_tuple(root) do
    new(root)
  end
  def initialize(root) do
    cell = Cell.get_row_col(root)
    new(cell)
  end

  defp new(root) do
    cells = %{root => 0}
    %Distances{root: root, cells: cells}
  end

  def distance(distances, cell) when is_tuple(cell) do
    Map.get(distances.cells, cell)
  end
  def distance(distances, cell) do
    Map.get(distances.cells, Cell.get_row_col(cell))
  end

  def put(distances, cell, distance) when is_tuple(cell) do
    %Distances{distances | cells: Map.put(distances.cells, cell, distance)}
  end
  def put(distances, cell, distance) do
    %Distances{distances | cells: Map.put(distances.cells, Cell.get_row_col(cell), distance)}
  end

  def cells(distances) do
    Map.keys(distances)
  end

  def path_to(grid, distances, goal) do
    current = Cell.get_row_col(goal)
    current_distance = distance(distances, current)
    breadcrumbs = Distances.initialize(distances.root)
    |> put(current, current_distance)
    path_to(grid, distances, breadcrumbs, current)
  end

  defp path_to(grid, distances, breadcrumbs, current) do
    if current == distances.root do
      breadcrumbs
    else
      current_cell = Grid.get_cell(grid, current)
      {neighbor, min_distance} = get_shortest_neighbor(distances, current_cell)
      breadcrumbs = put(breadcrumbs, neighbor, min_distance)
      path_to(grid, distances, breadcrumbs, neighbor)
    end
  end

  defp get_shortest_neighbor(distances, current) do
    Enum.map(current.links, fn {k, _v} -> {k, distance(distances, k)} end)
    |> Enum.min_by(fn {_, d} -> d end) 
  end

  def max(distances) do
    max_distance = 0
    max_cell = distances.root
    Enum.reduce(distances.cells, {max_cell, max_distance}, fn {cell, distance}, {acc_c, acc_d} -> 
      if distance > acc_d do
        {cell, distance}
      else
        {acc_c, acc_d}
      end
    end)
  end
end
