defmodule Distances do
  defstruct [:root, :cells]

  def initialize(root) do
    cell = Cell.get_row_col(root)
    cells = %{cell => 0}
    %Distances{root: cell, cells: cells}
  end

  def distance(distances, cell) when is_tuple(cell) do
    Map.get(distances.cells, cell)
  end
  def distance(distances, cell) do
    Map.get(distances.cells, Cell.get_row_col(cell))
  end

  def put(distances, cell, distance) when is_tuple(cell) do
    %Distances{distances | cells: Map.put(distances.cells, cell, distance)}
  end
  def put(distances, cell, distance) do
    %Distances{distances | cells: Map.put(distances.cells, Cell.get_row_col(cell), distance)}
  end

  def cells(distances) do
    Map.keys(distances)
  end
end
