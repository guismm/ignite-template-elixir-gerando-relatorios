defmodule GenReport do
  alias GenReport.{Months, Parser}

  def build(), do: {:error, "Insira o nome de um arquivo"}

  def build(file_name) when not is_bitstring(file_name) or file_name == "",
    do: {:error, "Insira o nome de um arquivo"}

  def build(file_name) do
    file_name
    |> Parser.parse_file()
    |> format_report()
  end

  def format_report(report_data) do
    names =
      report_data
      |> Enum.uniq_by(fn [name | _] -> name end)
      |> Enum.map(fn [name | _] -> name end)

    years =
      report_data
      |> Enum.uniq_by(fn [_, _, _, _, year] -> year end)
      |> Enum.map(fn [_, _, _, _, year] -> year end)

    report_data
    |> Enum.reduce(report_accumulator(names, years), fn line, report ->
      sum_values(line, report)
    end)
  end

  defp report_accumulator(names, years) do
    months = Months.get()

    all_hours =
      names
      |> Enum.reduce(%{}, fn name, result -> Map.put(result, name, 0) end)

    hours_per_month =
      names
      |> Enum.reduce(%{}, fn name, result ->
        name_months =
          months
          |> Enum.reduce(%{}, fn {_key, value}, months_acc -> Map.put(months_acc, value, 0) end)

        Map.put(result, name, name_months)
      end)

    hours_per_year =
      names
      |> Enum.reduce(%{}, fn name, result ->
        name_years =
          years
          |> Enum.reduce(%{}, fn year, years_acc -> Map.put(years_acc, year, 0) end)

        Map.put(result, name, name_years)
      end)

    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end

  defp sum_values([name, hours, _day, month, year], %{
         "all_hours" => all_hours,
         "hours_per_month" => hours_per_month,
         "hours_per_year" => hours_per_year
       }) do
    all_hours = Map.put(all_hours, name, all_hours[name] + hours)

    month_name_values = get_in(hours_per_month, [name])
    month_name_values = Map.put(month_name_values, month, month_name_values[month] + hours)
    hours_per_month = Map.put(hours_per_month, name, month_name_values)

    year_name_values = get_in(hours_per_year, [name])
    year_name_values = Map.put(year_name_values, year, year_name_values[year] + hours)
    hours_per_year = Map.put(hours_per_year, name, year_name_values)

    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end
end
