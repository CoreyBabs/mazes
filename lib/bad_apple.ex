defmodule BadApple do
  
  def process() do
    path = "/home/corey/Downloads/frames/"
    new_path = "/home/corey/Downloads/frames/new_frames/"
    {:ok, files} = File.ls(path)
    files = Enum.filter(files, fn f -> Path.extname(f) == ".png" end)

    Task.async_stream(files, fn file ->
      IO.puts("Processing #{file}")
      
      new_img = Path.join(new_path, file)
      {:ok, new_files} = File.ls(new_path)
      case Enum.member?(new_files, file) do
        true -> new_img
        false ->
          full_path = Path.join(path, file)
          Mask.from_png(full_path)
          |> Grid.initialize()
          |> ModifiedRecursiveBacktracker.on()
          |> Grid.to_png(4)
          |> ExPng.Image.to_file(new_img)

          count = length(new_files)
          IO.puts("#{count} have been processed")
          new_img
      end
    end, max_concurrency: 8, timeout: :infinity)
    |> Enum.to_list()
  end
end
