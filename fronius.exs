defmodule Fronius do
  use ExSunspec, start: 40_001,
                 models: [1, 111, 120, 121, 122, 123],
                 model_1_length_65: true
  field :model_type, :uint16, 216, 1, :rw, "Type of SunSpec models used for inverter and meter data. Write 1 or 2 and then immediately 6 to acknowledge setting.", enum_map: %{1 => "Floating point", 2 => "Integer & SF"}

  def get_field(name) do
    field_defs()
    |> Enum.find(fn(val) ->
      case val do
        {^name, _, _, _, _, _, _, _} -> true
        _ -> false
      end
    end)
  end
end
