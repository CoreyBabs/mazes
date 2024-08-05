defmodule PolarCell do
   
  defstruct [:row, :col, :cw, :ccw, :inward, :outward, :links]

  def initialize(row, col) do
    %PolarCell{row: row, col: col, outward: [], links: %{}}
  end

  def neighbors(pcell) do
    list = [pcell.cw, pcell.ccw, pcell.inward]
    |> Enum.filter(fn dir -> dir != nil end)
    |> Enum.to_list()
    list ++ pcell.outward
  end

  def update_neighbors(cell, parent, cw, ccw) do
    %PolarCell{cell | cw: cw, ccw: ccw, inward: parent} 
  end

  def update_outward(cell, outward) do
    %PolarCell{cell | outward: cell.outward ++ [outward]}
  end

  def link(cell, linked) do
    new_links = cell.links
    new_links = Map.put(new_links, {linked.row, linked.col}, true)
    %PolarCell{cell | links: new_links}
  end

  def link_cells(cell, linked) do
    new_cell = link(cell, linked)
    new_linked = link(linked, new_cell)

    {new_cell, new_linked}
  end
end
