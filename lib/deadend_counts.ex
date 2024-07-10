defmodule DeadendCounts do
  def count_deadends() do
    tries = 100
    size = 20

    algorithms = [BinaryTree, Sidewinder, AldousBroder, Wilsons, HuntAndKill]
    averages = Enum.reduce(algorithms, %{}, fn algo, acc -> 
      deadend_counts = Enum.reduce(0..(tries - 1), [], fn _, acc_d ->
        count = run_algorithm(algo, size)
        acc_d ++ [count]
      end)

      total = Enum.sum(deadend_counts)
      Map.put(acc, algo, total / tries)
    end)

    total_cells = size * size
    IO.puts("")
    IO.puts("Average deadends per #{size}x#{size} maze (#{total_cells} cells):")
    IO.puts("")

    Enum.sort_by(algorithms, fn algo -> averages[algo] end)
    |> Enum.each(fn sorted -> 
      percentage = averages[sorted] * 100.0 / (total_cells)
      IO.puts("#{sorted}: #{averages[sorted]}/#{total_cells}  (#{percentage}%)")
    end)
  end

  defp run_algorithm(algo, size) do
    Grid.initialize(size, size)
    |> algo.on()
    |> Grid.deadends()
    |> length()
  end
end
