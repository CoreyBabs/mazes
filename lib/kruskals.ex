defmodule Kruskals do
  defstruct [:neighbors, :set_for_cell, :cells_in_set]

  def initialize(grid) do
    state = %Kruskals{neighbors: [], set_for_cell: %{}, cells_in_set: %{}}
    Grid.each_cell(grid)
    |> Enum.reduce(state, fn c, acc ->
      cell = Cell.get_row_col(c)
      set = Map.keys(acc.set_for_cell) |> length()
      set_for_cell = Map.put(acc.set_for_cell, cell, set)
      cells_in_set = Map.put(acc.cells_in_set, set, [cell])

      neighbors = if c.south != nil, do: acc.neighbors ++ [[cell, c.south]], else: acc.neighbors
      neighbors = if c.east != nil, do: neighbors ++ [[cell, c.east]], else: neighbors

      %Kruskals{acc | neighbors: neighbors, set_for_cell: set_for_cell, cells_in_set: cells_in_set}
    end)
  end

  def can_merge?(state, left, right) do
    l = get_set_for_cell(state, left)
    r = get_set_for_cell(state, right)

    l != r #&& left != nil && right != nil
  end

  # def merge(state, %UnderCell{} = left, %Undercell{} = right) do
  #   
  # end
  def merge(state, left, right) do
    {left, right} = Cell.link_cells(left, right)

    winner = get_set_for_cell(state, left)
    loser = get_set_for_cell(state, right)
    losers = get_cells_in_set(state, loser)
    losers = if losers != nil, do: losers, else: [right |> Cell.get_row_col()]

    new_state = Enum.reduce(losers, state, fn l, acc ->
      cells = get_cells_in_set(acc, winner)
      # if cells == nil do
      #   IO.inspect(acc)
      #   IO.inspect(winner)
      #   IO.inspect(loser)
      #   IO.inspect(losers)
      #   # IO.inspect(left)
      #   # IO.inspect(right)
      # end
      # cells = if cells == nil, do: [], else: cells
      cells_in_set = Map.put(acc.cells_in_set, winner, cells ++ [l])
      set_for_cell = Map.put(acc.set_for_cell, l, winner)

      %Kruskals{acc | set_for_cell: set_for_cell, cells_in_set: cells_in_set}
    end)

    if winner == loser do
      IO.inspect(left)
      IO.inspect(right)
      raise "SOMETHING IS WRONG"
    end
    updated_set = Map.delete(new_state.cells_in_set, loser)
    {{left, right}, %Kruskals{new_state | cells_in_set: updated_set}}
  end

  def check_and_add_crossing(grid, state, cell) do
    can_cross = (Cell.links(cell) |> Enum.any?())
      || !can_merge?(state, Grid.get_cell(grid, cell.east), Grid.get_cell(grid, cell.west))
      || !can_merge?(state, Grid.get_cell(grid, cell.north), Grid.get_cell(grid, cell.south))

    can_cross = !can_cross

    case can_cross do
      false ->
        IO.puts("not crossing")
        # IO.inspect(state)
        {grid, state}
      true -> 
        IO.puts("Crossing")
        {g, s} = add_crossing(grid, state, cell)
        # IO.inspect(s)
        {g, s}
    end
  end

  defp add_crossing(grid, state, cell) do
    c = Cell.get_row_col(cell)
    neighbors = Enum.reject(state.neighbors, fn [left, right] -> left == c || right == c end)
    state = %Kruskals{state | neighbors: neighbors}

    west = Grid.get_cell(grid, cell.west)
    east = Grid.get_cell(grid, cell.east)
    north = Grid.get_cell(grid, cell.north)
    south = Grid.get_cell(grid, cell.south)
    if :rand.uniform(2) == 1 do
      {{west, cell}, state} = merge(state, west, cell)
      grid = update_merged_cells(grid, west, cell)
      {{cell, east}, state} = merge(state, cell, east)
      grid = update_merged_cells(grid, cell, east)

      grid = WeaveGrid.tunnel_under(grid, cell)

      northsouth = Grid.get_cell(grid, north.south)
      southnorth = Grid.get_cell(grid, south.north)

      {{north, northsouth}, state} = merge(state, north, northsouth)
      grid = update_merged_cells(grid, north, northsouth)
      {{south, southnorth}, state} = merge(state, south, southnorth)
      grid = update_merged_cells(grid, south, southnorth)  
      {grid, state}
    else
      {{north, cell}, state} = merge(state, north, cell)
      grid = update_merged_cells(grid, north, cell)
      {{cell, south}, state} = merge(state, cell, south)
      grid = update_merged_cells(grid, cell, south)

      grid = WeaveGrid.tunnel_under(grid, cell)

      westeast = Grid.get_cell(grid, west.east)
      eastwest = Grid.get_cell(grid, east.west)

      {{west, westeast}, state} = merge(state, west, westeast)
      grid = update_merged_cells(grid, west, westeast)
      {{east, eastwest}, state} = merge(state, east, eastwest)
      grid = update_merged_cells(grid, east, eastwest)  
      {grid, state}
    end
  end

  def on(grid) do
    state = initialize(grid)
    on(grid, state)
  end
  def on(grid, state) do
    neighbors = Enum.shuffle(state.neighbors)
    {grid, _state} = loop_neighbors(grid, state, neighbors)
    grid
  end

  defp loop_neighbors(grid, state, neighbors) when length(neighbors) == 0 do
    {grid, state}
  end
  defp loop_neighbors(grid, state, neighbors) do
    {[left, right], neighbors} = List.pop_at(neighbors, -1)
    left = Grid.get_cell(grid, left)
    right = Grid.get_cell(grid, right)
    {grid, state} = if can_merge?(state, left, right) do
     {{left, right}, state} = merge(state, left, right)
      grid = update_merged_cells(grid, left, right)
      {grid, state}
    else
      {grid, state}
    end

    loop_neighbors(grid, state, neighbors)
  end

  defp update_merged_cells(%WeaveGrid{} = grid, left, right) do
    WeaveGrid.update_grid_with_cells(grid, [left, right]) 
  end
  defp update_merged_cells(grid, left, right) do
    grid = Grid.update_grid_with_cell(left, grid)
    Grid.update_grid_with_cell(right, grid)
  end

  defp get_set_for_cell(state, cell) do
    Map.get(state.set_for_cell, Cell.get_row_col(cell))
  end

  defp get_cells_in_set(state, set) do
    Map.get(state.cells_in_set, set)
  end
end
