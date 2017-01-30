defmodule Mix.Tasks.Sunspec.GenTestData do
  use Mix.Task

  alias NimbleCSV.RFC4180, as: CSV

  @path_to_test [__DIR__, "..", "..", "..", "test"]
  @shortdoc "converts raw fronius csv specs to ExSunspec format"
  def run(_args) do
    File.mkdir Path.join(@path_to_test ++ ["test_fronius_inverter_intsf"])
    input_csvs = Path.join(@path_to_test ++ ["raw_fronius_inverter_intsf"])
    |> File.ls!
    |> Enum.filter(fn(file) -> ".csv" == Path.extname(file) end)

    output_csvs = input_csvs
    |> Enum.map(&Path.basename(&1))

    for {inp, out} <- Enum.zip(input_csvs, output_csvs) do
      csv_lines = File.stream!(Path.join(@path_to_test ++ ["raw_fronius_inverter_intsf", inp]), [], :line)
      |> Enum.filter(&Regex.match?(~r/^\d+,/, &1))
      |> Enum.flat_map(&CSV.parse_string(&1, headers: false))
      |> Enum.map(&map_lines(&1))
      |> CSV.dump_to_iodata

      File.write!(Path.join(@path_to_test ++ ["test_fronius_inverter_intsf", out]), csv_lines)
    end
  end

  def map_lines([start, _end, _size, access, _func_codes, name, desc, type, units, sf, range]) do
    [start, ":#{String.downcase(type)}", String.downcase(access), name, String.trim("(#{name} Units: #{units} SF: #{sf}) #{desc} - Range: #{range}")]
  end
end
