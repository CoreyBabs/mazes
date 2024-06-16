defmodule Sidewinder do

  def on(grid) do
    Grid.each_row(grid)
    |> Enum.reduce(grid, fn row, acc -> update_row(acc, row) end)

  end

  defp update_row(grid, row) do
    run = []
    {grid, _run} = Enum.reduce(row, {grid, run}, fn cell, {acc_g, acc_r} ->
      {cells, acc_r} = update_cell(acc_g, cell, acc_r)
      new_grid = Grid.update_grid_with_cells(acc_g, Tuple.to_list(cells))
      {new_grid, acc_r}
    end)

    grid
  end

  defp update_cell(grid, cell, run) do
    cell = Grid.get_cell(grid, Cell.get_row_col(cell))
    new_run = run ++ [cell]
    at_east = cell.east == nil
    at_north = cell.north == nil

    should_close = at_east || (!at_north && Enum.random(0..1) == 0)
    do_nothing = at_east && at_north


    case {should_close, do_nothing} do
      {true, false} -> member = Enum.random(new_run)
              {Cell.link_cells(member, Grid.get_cell(grid, member.north)), []}
      {false, false} -> 
        {new_cell, linked_cell} = Cell.link_cells(cell, Grid.get_cell(grid, cell.east))
        {{new_cell, linked_cell}, run ++ [new_cell]}
      {_, _} -> {{nil, nil}, []}
    end
  end
  
end
