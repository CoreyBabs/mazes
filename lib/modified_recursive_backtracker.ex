defmodule ModifiedRecursiveBacktracker do
  def on(grid) do
    case Grid.has_unlinked_cell?(grid) do
      true ->
        loop_section(grid)
        |> on()
      false -> grid
    end
  end

  defp loop_section(grid) do
    start = get_random_cell(grid)
    loop_through_stack(grid, [start])
  end

  def loop_through_stack(grid, stack) do
    case stack do
      [] -> grid
      _ ->
        current = List.last(stack) |> Cell.get_row_col()
        current = Grid.get_cell(grid, current)
        neighbors = Cell.neighbors(current)
        |> Enum.filter(fn c -> Grid.get_cell(grid, c) |> Cell.links() |> Enum.empty?() end)
        |> Enum.map(fn n -> Grid.get_cell(grid, n) end)

        case neighbors do
          [] -> loop_through_stack(grid, List.delete_at(stack, -1))
          _ ->
            neighbor = Enum.random(neighbors)
            grid = Grid.link_cells_and_update_grid(grid, current, neighbor)
            stack = stack ++ [Grid.get_cell(grid, Cell.get_row_col(neighbor))]
            loop_through_stack(grid, stack)
        end
    end 
  end

  defp get_random_cell(grid) do
    Grid.each_cell(grid)
    |> Enum.filter(fn c -> c != nil end)
    |> Enum.filter(fn c -> Mask.get(grid.mask, Cell.get_row_col(c)) && Cell.links(c) |> Enum.empty?() end)
    |> Enum.filter(fn c -> Cell.neighbors(c) |> Enum.any?() end)
    |> Enum.random()
  end
end
