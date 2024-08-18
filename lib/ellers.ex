defmodule Ellers do
  defstruct [:next_set, :set_for_cell, :cells_in_set]

  def initialize(starting_set \\ 0) do
    %Ellers{set_for_cell: %{}, cells_in_set: %{}, next_set: starting_set}
  end

  def record(state, set, cell) do
    set_for_cell = Map.put(state.set_for_cell, cell.col, set)

    cells = get_cells_in_set(state, set)
    cells = if cells == nil, do: [], else: cells 
    cells_in_set = Map.put(state.cells_in_set, set, cells ++ [Cell.get_row_col(cell)])

    %Ellers{state | set_for_cell: set_for_cell, cells_in_set: cells_in_set}
  end

  def set_for(state, cell) do
    set = get_set_for_cell(state, cell)
    state = if set == nil do
      state = record(state, state.next_set, cell)
      %Ellers{state | next_set: state.next_set + 1}
    else
      state
    end

    {state, get_set_for_cell(state, cell)}
  end

  def merge(state, winner, loser) do
    new_state = get_cells_in_set(state, loser)
    |> Enum.reduce(state, fn l, acc ->
      set_for_cell = Map.put(acc.set_for_cell, elem(l, 1), winner)
      cells = get_cells_in_set(acc, winner)
      cells_in_set = Map.put(acc.cells_in_set, winner, cells ++ [l])
      %Ellers{acc | set_for_cell: set_for_cell, cells_in_set: cells_in_set}
    end)

    updated_set = Map.delete(new_state.cells_in_set, loser)
    %Ellers{new_state | cells_in_set: updated_set}
  end

  def next(state) do
    initialize(state.next_set)
  end

  def each_set(state) do
    Enum.map(state.cells_in_set, fn {k, v} -> {k, v} end)
  end

  def on(grid) do
    state = Ellers.initialize()

    {grid, _state} = Grid.each_row(grid)
    |> Enum.reduce({grid, state}, fn row, {acc_g, acc_s} ->
      {acc_g, acc_s} = Enum.reduce(row, {acc_g, acc_s}, fn cell, {g, s} ->
        cell = Grid.get_cell(g, Cell.get_row_col(cell))
        if cell.west != nil do
          west = Grid.get_cell(g, cell.west)
          {s, set} = set_for(s, cell)
          {s, prior} = set_for(s, west)

          should_link = set != prior && (cell.south == nil || Enum.random(0..1) == 0)
          g = link_cells(g, cell, west, should_link)
          s = merge(s, prior, set)
          {g, s}
        else
          {g, s}
        end
      end)

      first = Enum.at(row, 0)
      if first.south != nil do
        next_row = next(acc_s)

        {acc_g, next_row} = each_set(acc_s)
        |> Enum.reduce({acc_g, next_row}, fn {_k, v}, {g, s} ->
            Enum.shuffle(v) |> Enum.with_index()
            |> Enum.reduce({g, s}, fn {cell, index}, {gg, ss} ->
              if (index == 0 || Enum.random(0..2) == 0) do
                cell = Grid.get_cell(gg, cell)
                south = Grid.get_cell(gg, cell.south)
                gg = link_cells(gg, cell, south, true)
                {ss, set} = set_for(ss, cell)
                ss = record(ss, set, south)
                {gg, ss}
              else
                {gg, ss}
              end
            end)
          end)
        {acc_g, next_row}
      else
        {acc_g, acc_s}
      end
    end)

    grid
  end

  defp link_cells(grid, cell, linked, should_link) do
    case should_link do
      true -> Grid.link_cells_and_update_grid(grid, cell, linked)
      false -> grid
    end
  end

  defp get_set_for_cell(state, cell) do
    {_row, col} = Cell.get_row_col(cell)
    Map.get(state.set_for_cell, col)
  end

  defp get_cells_in_set(state, set) do
    Map.get(state.cells_in_set, set)
  end
end
