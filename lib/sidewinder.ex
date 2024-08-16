defmodule Sidewinder do

  def on(grid) do
    Grid.each_row(grid)
    |> Enum.reduce(grid, fn row, acc -> update_row(acc, row) end)

  end

  defp update_row(grid, row) do
    run = []
    {grid, _run} = Enum.reduce(row, {grid, run}, fn cell, {acc_g, acc_r} ->
      {{cell, linked}, acc_r} = get_cells_to_update(acc_g, cell, acc_r)
      new_grid = Grid.link_cells_and_update_grid(acc_g, cell, linked)

      # Update run to include linked cells. This can be optimized to only update the last cell in the run
      acc_r = Enum.map(acc_r, fn c -> Grid.get_cell(new_grid, Cell.get_row_col(c)) end)
      {new_grid, acc_r}
    end)

    grid
  end

  defp get_cells_to_update(grid, cell, run) do
    cell = Grid.get_cell(grid, Cell.get_row_col(cell))
    new_run = run ++ [cell]
    east = Grid.get_cell(grid, cell.row, cell.col + 1) |> Cell.get_row_col()
    at_east = east == nil
    at_north = cell.north == nil

    should_close = at_east || (!at_north && Enum.random(0..1) == 0)
    do_nothing = at_east && at_north


    case {should_close, do_nothing} do
      {true, false} -> member = Enum.random(new_run)
              {{member, Grid.get_cell(grid, member.north)}, []}
      {false, false} -> 
        {{cell, Grid.get_cell(grid, east)}, run ++ [cell]}
      {_, _} -> {{nil, nil}, []}
    end
  end
end
