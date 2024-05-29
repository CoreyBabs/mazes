defmodule SidewinderDemo do
  def demo() do
    Grid.initialize(4, 4)
    |> Sidewinder.on()
    |> Grid.to_string()
    |> IO.puts()
  end
end
