defmodule HuntAndKill do
  def on(grid) do
    cell = Grid.random_cell(grid)
    check_and_loop_cells(grid, cell)
  end

  defp check_and_loop_cells(grid, cell) do
    case cell do
      nil -> grid
      _ ->
        unvisited_neighbors = Cell.neighbors(cell) |> Enum.filter(fn c -> Grid.get_cell(grid, c) |> Cell.links() |> Enum.empty?() end)
        {grid, current} = check_neighbors(grid, cell, unvisited_neighbors)
        check_and_loop_cells(grid, current)
    end
  end

  defp check_neighbors(grid, cell, unvisited) do
    case unvisited do
      [] -> hunt_for_neighbor(grid)
      _ -> link_neighbor(grid, cell, unvisited)
    end
  end

  defp link_neighbor(grid, cell, unvisited) do
    neighbor = Enum.random(unvisited)
    neighbor = Grid.get_cell(grid, neighbor)
    grid = Grid.link_cells_and_update_grid(grid, cell, neighbor)
    {grid, Grid.get_cell(grid, Cell.get_row_col(neighbor))}
  end

  defp hunt_for_neighbor(grid) do
    current = Grid.each_cell(grid) |> Enum.find(nil, fn cell ->
      visited_neighbors = Cell.neighbors(cell) |> Enum.filter(fn c -> Grid.get_cell(grid, c) |> Cell.links() |> Enum.any?() end)
      Cell.links(cell) |> Enum.empty?() && Enum.any?(visited_neighbors)
    end)

    case current do
      nil -> {grid, nil}
      _ -> 
        neighbor = Cell.neighbors(current)
          |> Enum.filter(fn c -> Grid.get_cell(grid, c) |> Cell.links()
            |> Enum.any?() end)
          |> Enum.random()

        neighbor = Grid.get_cell(grid, neighbor)
        grid = Grid.link_cells_and_update_grid(grid, current, neighbor)
        {grid, Grid.get_cell(grid, Cell.get_row_col(current))}
    end
  end
end
