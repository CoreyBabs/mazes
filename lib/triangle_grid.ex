defmodule TriangleGrid do
  
  defstruct [:rows, :cols, :cells]

  def initialize(rows, cols) do
    %TriangleGrid{rows: rows, cols: cols} 
    |> prepare_grid()
    |> configure_cells()
  end

  defp prepare_grid(tgrid) do
    cells = Enum.map(0..tgrid.rows - 1, fn row ->
      Enum.map(0..tgrid.cols - 1, fn col ->
          TriangleCell.initialize(row, col)
      end)
    end) 
    %TriangleGrid{tgrid | cells: cells}
  end

  defp configure_cells(tgrid) do
    Grid.each_cell(tgrid)
    |> Enum.filter(fn c -> c != nil end)
    |> Enum.reduce(tgrid, fn cell, acc ->
      {row, col} = Cell.get_row_col(cell)

      west = Grid.get_cell(acc, row, col - 1) |> Cell.get_row_col()
      east = Grid.get_cell(acc, row, col + 1) |> Cell.get_row_col()
      {north, south} = case TriangleCell.upright?(cell) do
        true -> {nil, Grid.get_cell(acc, row + 1, col) |> Cell.get_row_col()}
        false -> {Grid.get_cell(acc, row - 1, col) |> Cell.get_row_col(), nil}
      end
      
      update_cell_with_neighbors(acc, cell, north, south, east, west)
    end) 
  end

  defp update_cell_with_neighbors(tgrid, cell, north, south, east, west) do
    new_cell = Grid.get_cell(tgrid, cell.row, cell.col)
    |> TriangleCell.update_neighbors(north, south, east, west)

    update_grid_with_cell(tgrid, new_cell)
  end

  defp update_grid_with_cell(tgrid, cell) when cell == nil do
    tgrid
  end
  defp update_grid_with_cell(tgrid, cell) do
    new_col = Enum.at(tgrid.cells, cell.row)
    |> List.update_at(cell.col, fn _ -> cell end)

    new_cells = List.update_at(tgrid.cells, cell.row, fn _ -> new_col end)
    %TriangleGrid{tgrid | cells: new_cells}
  end

  def update_grid_with_cells(tgrid, cells) do
    Enum.reduce(cells, tgrid, fn cell, acc -> update_grid_with_cell(acc, cell) end)
  end

  def to_png(tgrid, size \\ 16) do
    half_width = size / 2.0
    height = size * :math.sqrt(3) / 2.0
    half_height = height / 2.0

    img_width = (size * (tgrid.cols + 1) / 2.0) |> trunc()
    img_height = (height * tgrid.rows) |> trunc()

    wall = ExPng.Color.black()
    img = ExPng.Image.new(img_width + 1, img_height + 1)

    # TODO: Implement colors
    Grid.each_cell(tgrid)
    |> Enum.reduce(img, fn cell, acc ->
      cx = half_width + cell.col * half_width
      cy = half_height + cell.row * height

      west_x = (cx - half_width) |> trunc()
      mid_x = cx |> trunc()
      east_x = (cx + half_width) |> trunc()

      is_upright = TriangleCell.upright?(cell)
      {apex_y, base_y} = case is_upright do
        true ->
          ay = (cy - half_height) |> trunc()
          by = (cy + half_height) |> trunc()
          {ay, by}
        false ->
          ay = (cy + half_height) |> trunc()
          by = (cy - half_height) |> trunc()
          {ay, by}
      end

      acc = acc 
      |> draw_line({west_x, base_y}, {mid_x, apex_y}, wall, cell.west)
      |> draw_line({east_x, base_y}, {mid_x, apex_y}, wall, Cell.linked?(cell, cell.east))

      no_south = is_upright && cell.south == nil
      not_linked = !is_upright && !Cell.linked?(cell, cell.north)

      if no_south || not_linked do
        ExPngExtensions.line(acc, {east_x, base_y}, {west_x, base_y}, wall)
      else
        acc
      end
    end) 
  end

  defp draw_line(img, coords0, coords1, color, pred) do
    unless pred do
      ExPngExtensions.line(img, coords0, coords1, color)
    else
      img
    end
  end
end
