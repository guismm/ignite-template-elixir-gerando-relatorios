defmodule GenReport.Parser do
  alias GenReport.Months

  def parse_file(file_name) do
    file_name
    |> File.stream!()
    |> Stream.map(&parse_line/1)
  end

  defp parse_line(line) do
    months = Months.get()

    line
    |> String.trim()
    |> String.split(",")
    |> List.update_at(0, &String.downcase/1)
    |> List.update_at(1, &String.to_integer/1)
    |> List.update_at(2, &String.to_integer/1)
    |> List.update_at(3, fn elem -> months[elem] end)
    |> List.update_at(4, &String.to_integer/1)
  end
end
