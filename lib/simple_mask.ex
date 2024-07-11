defmodule SimpleMask do
  def on() do
    Mask.initialize(5, 5)
    |> Mask.set(0, 0, false)
    |> Mask.set(2, 2, false)
    |> Mask.set(4, 4, false)
    |> Grid.initialize()
    |> RecursiveBacktracker.on()
    |> Grid.to_string()
    |> IO.puts()
  end
end
