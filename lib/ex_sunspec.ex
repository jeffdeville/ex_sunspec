defmodule ExSunspec do
  use ExModbus
  @sid_len 2
  defmacro __using__(start: start, models: model_ids) do
    alias ExSunspec.ModelDefs
    import ExSunspec.Modbus

    fields_ast = model_ids
    |> Enum.map(&ModelDefs.load/1)
    |> fieldify(start + @sid_len, [])
    |> Enum.map(fn({name, type, address, len, access, desc, units, enum_map}) ->
      quote bind_quoted: [name: name, type: type, address: address, len: len,
                          access: access, desc: desc, units: units,
                          enum_map: Macro.escape(enum_map)] do
        IO.puts inspect [name, address]
        field name, type, address, len, access, desc, units, enum_map
      end
    end)

    quote do
      use ExModbus
      unquote(fields_ast)
    end
  end
end
