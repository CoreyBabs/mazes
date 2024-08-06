defmodule HexCell do
  
  defstruct [:row, :col, :north, :northeast, :northwest, :south, :southeast, :southwest, :links]

  def initialize(row, col) do
    %HexCell{row: row, col: col, links: %{}}
  end

  def neighbors(hcell) do
    [hcell.north, hcell.northeast, hcell.northwest, hcell.south, hcell.southeast, hcell.southwest]
    |> Enum.filter(fn dir -> dir != nil end)
    |> Enum.to_list()
  end

  def update_neighbors(hcell, north, ne, nw, south, se, sw) do
    %HexCell{ hcell |
      north: north,
      northeast: ne,
      northwest: nw,
      south: south,
      southeast: se,
      southwest: sw
    } 
  end

  def link(cell, linked) do
    new_links = cell.links
    new_links = Map.put(new_links, {linked.row, linked.col}, true)
    %HexCell{cell | links: new_links}
  end

  def link_cells(cell, linked) do
    new_cell = link(cell, linked)
    new_linked = link(linked, new_cell)

    {new_cell, new_linked}
  end
end
