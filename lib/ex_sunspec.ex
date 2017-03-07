defmodule ExSunspec do
  use ExModbus
  @sid_len 2
  defmacro __using__(opts) do
    start = opts[:start]
    model_ids = opts[:models]
    overrides = case Keyword.has_key?(opts, :overrides) do
      true ->
        {overrides, _} = Code.eval_quoted(opts[:overrides])
        overrides
      false -> %{}
    end
    model_1_length_65 = Keyword.get(opts, :model_1_length_65, false)
    overrides = case model_1_length_65 do
      true -> Map.merge(overrides, %{1 => %{length: 65}})
      false -> overrides
    end

    alias ExSunspec.ModelDefs
    import ExSunspec.Modbus

    fields_ast = model_ids
    |> Enum.map(&ModelDefs.load(&1, overrides))
    |> fieldify(start + @sid_len, [])
    |> Enum.map(fn({name, type, address, len, access, desc, units, enum_map}) ->
      quote bind_quoted: [name: name, type: type, address: address, len: len,
                          access: access, desc: desc, units: units,
                          enum_map: Macro.escape(enum_map)] do
        # IO.puts inspect [name, address]
        field name, type, address, len, access, desc, units: units, enum_map: enum_map
      end
    end)

    quote do
      use ExModbus
      unquote(fields_ast)
    end
  end
end
