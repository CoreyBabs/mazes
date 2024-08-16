defmodule Wilsons do
  def on(grid) do
    unvisited = []
    unvisited = Grid.each_cell(grid) |> Enum.reduce(unvisited, fn cell, acc -> acc ++ [cell] end)
    first = Enum.random(unvisited)
    unvisited = List.delete(unvisited, first)
    loop_through_cells(grid, unvisited)
  end

  defp loop_through_cells(grid, unvisited) do
    case unvisited do
      [] -> grid
      _ ->
        cell = Enum.random(unvisited)
        path = [cell]
        
        path = loop_through_path(grid, cell, unvisited, path)
        len = length(path)

        {grid, unvisited} = Enum.reduce(0..(len-2), {grid, unvisited}, fn i, {acc_g, acc_u} ->
          c = Enum.at(path, i) |> Cell.get_row_col()
          c = Grid.get_cell(acc_g, c)
          n = Enum.at(path, i + 1) |> Cell.get_row_col()
          n = Grid.get_cell(acc_g, n)
          
          g = Grid.link_cells_and_update_grid(acc_g, c, n)
          u = Enum.filter(acc_u, fn uc -> !Cell.eq?(c, uc) end)

          {g, u}
        end)
        loop_through_cells(grid, unvisited)
    end 
  end

  defp loop_through_path(grid, cell, unvisited, path) do
    if Enum.any?(unvisited, fn c -> Cell.eq?(c, cell) end) do
      new_cell = Cell.neighbors(cell) |> Enum.random()
      new_cell = Grid.get_cell(grid, new_cell)
      position = Enum.find_index(path, fn c -> Cell.eq?(c, new_cell) end)
      path = case position do
        nil -> path ++ [new_cell]
        _ -> Enum.slice(path, 0, position + 1)
      end

      loop_through_path(grid, new_cell, unvisited, path)
    else
      path
    end 
  end
end
