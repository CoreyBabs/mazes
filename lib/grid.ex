defmodule Grid do

  defstruct [:rows, :cols, :cells, mask: nil]

  def initialize(rows, cols) do
    %Grid{rows: rows, cols: cols} 
    |> prepare_grid()
    |> configure_cells()
  end
  
  def initialize(mask) do
    %Grid{rows: mask.rows, cols: mask.cols, mask: mask} 
    |> prepare_grid()
    |> configure_cells()
  end

  def prepare_grid(grid) do
    cells = Enum.map(0..grid.rows - 1, fn row ->
      Enum.map(0..grid.cols - 1, fn col ->
        if grid.mask == nil or Mask.get(grid.mask, row, col) do
          Cell.initialize(row, col)
        else
          nil
        end
      end)
    end) 
    %Grid{grid | cells: cells}
  end

  def configure_cells(grid) do
    each_cell(grid)
    |> Enum.filter(fn c -> c != nil end)
    |> Enum.reduce(grid, fn cell, acc ->  
      north = get_cell(acc, cell.row - 1, cell.col) |> Cell.get_row_col()
      east = get_cell(acc, cell.row, cell.col + 1) |> Cell.get_row_col()
      south = get_cell(acc, cell.row + 1, cell.col) |> Cell.get_row_col()
      west = get_cell(acc, cell.row, cell.col - 1) |> Cell.get_row_col()
      update_cell_with_neighbors(acc, cell.row, cell.col, north, east, south, west)
    end)
  end

  def random_cell(%Grid3d{} = grid) do
    Grid3d.random_cell(grid)
  end
  def random_cell(grid) when grid.mask != nil do
    {rand_row, rand_col} = Mask.random_location(grid.mask)
    get_cell(grid, rand_row, rand_col)
  end
  def random_cell(grid) do
    rand_row = Enum.random(0..grid.rows - 1)
    rand_col = Enum.random(0..grid.cols - 1)

    get_cell(grid, rand_row, rand_col)
  end

  def size(grid) do
    case grid.mask do
      nil -> grid.rows * grid.cols
      _ -> Mask.count(grid.mask)
    end
  end

  def each_row(grid) do
    Enum.map(grid.cells, fn row -> row end)
  end

  def each_cell(%WeaveGrid{} = grid) do
    WeaveGrid.each_cell(grid)
  end
  def each_cell(%Grid3d{} = grid) do
    Grid3d.each_cell(grid)
  end
  def each_cell(grid) do
    each_row(grid)
    |> Enum.flat_map(fn col -> col end)
  end

  def update_grid_with_cell(cell, grid) when cell == nil do
    grid
  end
  def update_grid_with_cell(cell, %CylinderGrid{} = grid) do
    CylinderGrid.update_grid_with_cell(cell, grid)
  end
  def update_grid_with_cell(cell, grid) do
    new_col = Enum.at(grid.cells, cell.row)
    |> List.update_at(cell.col, fn _ -> cell end)

    new_cells = List.update_at(grid.cells, cell.row, fn _ -> new_col end)
    %Grid{grid | cells: new_cells}
  end

  defp update_grid_with_cells(%PolarGrid{} = grid, cells) do
    PolarGrid.update_grid_with_cells(grid, cells)
  end
  defp update_grid_with_cells(%HexGrid{} = grid, cells) do
    HexGrid.update_grid_with_cells(grid, cells)
  end
  defp update_grid_with_cells(%TriangleGrid{} = grid, cells) do
    TriangleGrid.update_grid_with_cells(grid, cells)
  end
  defp update_grid_with_cells(%Grid3d{} = grid, cells) do
    Grid3d.update_grid_with_cells(grid, cells)
  end
  defp update_grid_with_cells(grid, cells) do
    Enum.reduce(cells, grid, fn cell, acc -> update_grid_with_cell(cell, acc) end)
  end

  def link_cells_and_update_grid(grid, cell, linked) when cell == nil or linked == nil do
    grid
  end
  def link_cells_and_update_grid(%WeaveGrid{} = grid, cell, linked) do
    result = OverCell.link_cells(cell, linked) 
    case result do
      {n, :tunnel} -> WeaveGrid.tunnel_under(grid, Grid.get_cell(grid, n))
      {c, n} -> WeaveGrid.update_grid_with_cells(grid, [c, n])
    end
    |> WeaveGrid.update_cells_with_grid()
  end
  def link_cells_and_update_grid(grid, cell, linked) do
    cells = Cell.link_cells(cell, linked) |> Tuple.to_list()
    update_grid_with_cells(grid, cells)
  end

  def to_string(grid, distances \\ nil) do
    output = "+" <> String.duplicate("---+", grid.cols) <> "\n"
    each_row(grid)
    |> Enum.reduce(output, fn row, acc -> 
      top = "|"
      bot = "+"
      {top, bot} = Enum.reduce(row, {top, bot}, fn cell, {top, bot} -> Cell.to_string(cell, top, bot, distances) end)
      acc = acc <> top <> "\n"
      acc <> bot <> "\n"
    end)
  end

  def to_png(grid, cell_size \\ 10, inset \\ 0) do
    cell_size = cell_size * 10
    img_width = cell_size * grid.cols
    img_height = cell_size * grid.rows
    inset = (cell_size * inset) |> trunc()

    wall = ExPng.Color.black()

    img = ExPng.Image.new(img_width + 1, img_height + 1)

    each_cell(grid)
    |> Enum.reduce(img, fn cell, acc -> Cell.draw_walls(cell, acc, cell_size, wall, inset) end) 
  end

  def to_png_with_color(grid, cell_size, distances, max, use_weights \\ false) do
    cell_size = cell_size * 10
    img_width = cell_size * grid.cols
    img_height = cell_size * grid.rows

    wall = ExPng.Color.black()

    img = ExPng.Image.new(img_width + 1, img_height + 1)

    img = case distances do
      nil -> img
      dists -> each_cell(grid)
        |> Enum.reduce(img, fn cell, acc ->
          dist = Distances.distance(dists, cell)
          Cell.draw_background(
            cell,
            acc,
            cell_size,
            Cell.background_color(dist, max, cell.weight, use_weights))
        end) 
    end

    each_cell(grid)
    |> Enum.reduce(img, fn cell, acc -> Cell.draw_walls(cell, acc, cell_size, wall, 0) end) 
  end

  def get_cell(_grid, row, col) when row < 0 or col < 0 do
    nil
  end  
  def get_cell(%CylinderGrid{} = grid, row, col) do
    CylinderGrid.get_cell(grid, row, col)
  end 
  def get_cell(grid, row, col) do
    case Enum.at(grid.cells, row) do
      nil -> nil
      cols -> Enum.at(cols, col)
    end
  end
  def get_cell(_grid, {row, col}) when row < 0 or col < 0 do
    nil
  end
  def get_cell(_grid, location) when location == nil do
    nil
  end
  def get_cell(%Grid3d{} = grid, {level, row, col}) do
    Grid3d.get_cell(grid, level, row, col)
  end 
  def get_cell(%CylinderGrid{} = grid, {row, col}) do
    CylinderGrid.get_cell(grid, row, col)
  end 
  def get_cell(grid, {row, col}) do
    case Enum.at(grid.cells, row) do
      nil -> nil
      cols -> Enum.at(cols, col)
    end
  end

  defp update_cell_with_neighbors(grid, row, col, north, east, south, west) do
    new_cell = Enum.at(grid.cells, row)
    |> Enum.at(col)
    |> Cell.update_neighbors(north, east, south, west)

    update_grid_with_cell(new_cell, grid)
  end

  def deadends(grid) do
    Grid.each_cell(grid)
    |> Enum.filter(fn cell -> Cell.links(cell)
      |> length() == 1
    end)
  end

  def braid(grid, p \\ 1.0) do
    grid
    |> deadends()
    |> Enum.shuffle()
    |> Enum.reduce(grid, fn cell, acc ->
      cell = get_cell(acc, cell.row, cell.col)
      if Cell.links(cell) |> length() != 1 || :rand.uniform() > p do
        acc
      else
        neighbors = Cell.neighbors(cell) |> Enum.reject(fn c -> Cell.linked?(cell, c) end)
        best = Enum.filter(neighbors, fn c -> get_cell(acc, c) |> Cell.links() |> length() == 1 end)
        best = case length(best) do
          0 -> neighbors
          _ -> best
        end

        neighbor = Enum.random(best)
        neighbor = get_cell(acc , neighbor)
        cells = Cell.link_cells(cell, neighbor) |> Tuple.to_list()
        update_grid_with_cells(acc, cells)
      end
    end)
  end

  def distances_from_cell(grid, cell) do
    distances = Distances.initialize(cell)
    frontier = [cell]

    distances_from_cell(grid, distances, frontier)
  end


  defp distances_from_cell(grid, distances, frontier) do
    case frontier do
      [] -> distances
      _f -> 
        {distances, frontier} = Enum.reduce(frontier, {distances, frontier}, fn c, {acc, nf} -> 
          Enum.reduce(c.links, {acc, nf}, fn {linked, _}, {acc_d, acc_f} -> 
            distances_of_linked(grid, acc_d, c, linked, acc_f)
          end)
        end)

        distances_from_cell(grid, distances, frontier)
    end
  end

  defp distances_of_linked(grid, distances, cell, linked, frontier) do
    case Distances.distance(distances, linked) do
      nil -> {Distances.put(distances, linked, Distances.distance(distances, cell) + 1), frontier ++ [get_cell(grid, linked)]}
      _distance -> {distances, List.delete(frontier, cell)}
    end
  end

  def weights_from_cell(grid, cell) do
    weights = Distances.initialize(cell)
    pending = [cell]

    weights_from_cell(grid, weights, pending)
  end

  defp weights_from_cell(grid, weights, pending) do
    case pending do
      [] -> weights
      _f -> 
      {w, p} = Enum.reduce(pending, {weights, pending}, fn _c, {acc, np} -> 
          cell = Enum.sort_by(np, fn c -> Distances.distance(acc, c) end) |> Enum.at(0)
          np = List.delete_at(np, 0)

          neighbors = Cell.links(cell)
          Enum.reduce(neighbors, {acc, np}, fn n, {acc_w, acc_n} ->
            neighbor = Grid.get_cell(grid, n)
            total_weight = Distances.distance(acc_w, cell) + neighbor.weight
            neighbor_weight = Distances.distance(acc, n)
            if neighbor_weight == nil || total_weight < neighbor_weight do
              acc_n = acc_n ++ [neighbor] 
              acc_w = Distances.put(acc_w, neighbor, total_weight)
              {acc_w, acc_n}
            else
              {acc_w, acc_n}
            end
          end)
          
        end)

        weights_from_cell(grid, w, p)
    end
  end
end
