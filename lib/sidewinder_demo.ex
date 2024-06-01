defmodule SidewinderDemo do
  def demo() do
    Grid.initialize(4, 4)
    |> Sidewinder.on()
    |> Grid.to_string()
    |> IO.puts()
  end

  def demo_image() do
    Grid.initialize(4, 4)
    |> Sidewinder.on()
    |> Grid.to_png(10)
    |> ExPng.Image.to_file("./images/sidewinder.png")
  end
end
