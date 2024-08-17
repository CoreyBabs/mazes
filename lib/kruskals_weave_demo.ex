defmodule KruskalsWeaveDemo do
  def demo() do
    grid = WeaveGrid.initialize(5, 5, true)
    state = Kruskals.initialize(grid)

    size = Grid.size(grid) - 1
    {grid, state} = Enum.reduce(0..size, {grid, state}, fn _i, {acc_g, acc_s} ->
      row = 1 + :rand.uniform(grid.rows - 3)
      col = 1 + :rand.uniform(grid.cols - 3)
      cell = Grid.get_cell(acc_g, {row, col})
      {g, s} = Kruskals.check_and_add_crossing(acc_g, acc_s, cell)
      {g, s}
    end)

    # start1 = Grid.get_cell(grid, {1, 1})
    # {grid, state} = Kruskals.check_and_add_crossing(grid, state, start1)
    # start2 = Grid.get_cell(grid, {3, 3})
    # {grid, state} = Kruskals.check_and_add_crossing(grid, state, start2)

    # IO.inspect(grid)
    # IO.inspect(state)

    Kruskals.on(grid, state)
    |> Grid.to_png(10, 0.1)
    |> ExPng.Image.to_file("./images/kruskals_weaved.png")
  end
end
