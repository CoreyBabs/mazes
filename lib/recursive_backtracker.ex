defmodule RecursiveBacktracker do
  def on(grid) do
    start = Grid.random_cell(grid)
    stack = [start]
    loop_through_stack(grid, stack)
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
end
