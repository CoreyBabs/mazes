defmodule HexGrid do
  require Integer
  
  defstruct [:rows, :cols, :cells]


  def initialize(rows, cols) do
    %HexGrid{rows: rows, cols: cols}
    |> prepare_grid()
    |> configure_cells()
  end

  defp prepare_grid(hgrid) do
    cells = Enum.map(0..hgrid.rows - 1, fn row ->
      Enum.map(0..hgrid.cols - 1, fn col ->
          HexCell.initialize(row, col)
      end)
    end) 
    %HexGrid{hgrid | cells: cells}
  end

  defp configure_cells(hgrid) do
    Grid.each_cell(hgrid)
    |> Enum.filter(fn c -> c != nil end)
    |> Enum.reduce(hgrid, fn cell, acc ->
      {row, col} = Cell.get_row_col(cell)

      {north_diag, south_diag} = if Integer.is_even(col) do
        {row - 1, row}
      else 
        {row, row + 1}
      end
      
      north = Grid.get_cell(acc, row - 1, col) |> Cell.get_row_col()
      nw = Grid.get_cell(acc, north_diag, col - 1) |> Cell.get_row_col()
      ne = Grid.get_cell(acc, north_diag, col + 1) |> Cell.get_row_col()
      south = Grid.get_cell(acc, row + 1, col) |> Cell.get_row_col()
      sw = Grid.get_cell(acc, south_diag, col - 1) |> Cell.get_row_col()
      se = Grid.get_cell(acc, south_diag, col + 1) |> Cell.get_row_col()
      
      update_cell_with_neighbors(acc, cell, north, ne, nw, south, se, sw)
    end) 
  end

  defp update_cell_with_neighbors(hgrid, cell, north, ne, nw, south, se, sw) do
    new_cell = Grid.get_cell(hgrid, cell.row, cell.col)
    |> HexCell.update_neighbors(north, ne, nw, south, se, sw)

    update_grid_with_cell(hgrid, new_cell)
  end

  defp update_grid_with_cell(hgrid, cell) when cell == nil do
    hgrid
  end
  defp update_grid_with_cell(hgrid, cell) do
    new_col = Enum.at(hgrid.cells, cell.row)
    |> List.update_at(cell.col, fn _ -> cell end)

    new_cells = List.update_at(hgrid.cells, cell.row, fn _ -> new_col end)
    %HexGrid{hgrid | cells: new_cells}
  end

  def update_grid_with_cells(hgrid, cells) do
    Enum.reduce(cells, hgrid, fn cell, acc -> update_grid_with_cell(acc, cell) end)
  end

  def to_png(hgrid, cell_size \\ 10) do
    a_size = cell_size / 2.0
    b_size = cell_size * :math.sqrt(3) / 2.0
    _width = cell_size * 2
    height = b_size * 2

    img_width = (3 * a_size * hgrid.cols + a_size + 0.5) |> trunc()
    img_height = (height * hgrid.rows + b_size + 0.5) |> trunc()
    
    img = ExPng.Image.new(img_width, img_height)
    wall = ExPng.Color.black()

    # TODO: implement colors
    Grid.each_cell(hgrid)
    |> Enum.reduce(img, fn cell, acc ->
      cx = cell_size + 3 * cell.col * a_size
      cy = if Integer.is_odd(cell.col) do
        b_size + cell.row * height + b_size
      else
        b_size + cell.row * height
      end

      x_fw = (cx - cell_size) |> trunc()
      x_nw = (cx - a_size) |> trunc()
      x_ne = (cx + a_size) |> trunc()
      x_fe = (cx + cell_size) |> trunc()
      y_n = (cy - b_size) |> trunc()
      y_m = cy |> trunc()
      y_s = (cy + b_size) |> trunc()

      acc 
      |> draw_line({x_fw, y_m}, {x_nw, y_s}, wall, cell.southwest)
      |> draw_line({x_fw, y_m}, {x_nw, y_n}, wall, cell.northwest)
      |> draw_line({x_nw, y_n}, {x_ne, y_n}, wall, cell.north)
      |> draw_line({x_ne, y_n}, {x_fe, y_m}, wall, Cell.linked?(cell, cell.northeast))
      |> draw_line({x_fe, y_m}, {x_ne, y_s}, wall, Cell.linked?(cell, cell.southeast))
      |> draw_line({x_ne, y_s}, {x_nw, y_s}, wall, Cell.linked?(cell, cell.south))
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
