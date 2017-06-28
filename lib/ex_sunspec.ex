defmodule ExSunspec do
  use ExModbus
  @sid_len 2
  defmacro __using__(opts) do
    start = opts[:start]
    model_ids = opts[:models]
    overrides = setup_overrides(opts)

    alias ExSunspec.ModelDefs
    import ExSunspec.Modbus

    model_defs = Enum.map(model_ids, &ModelDefs.load(&1, overrides))

    fields_ast = model_defs
      |> fieldify(start + @sid_len, [])
      |> Enum.map(fn({name, type, address, len, access, desc, units, enum_map}) ->
        quote bind_quoted: [name: name, type: type, address: address, len: len,
                            access: access, desc: desc, units: units,
                            enum_map: Macro.escape(enum_map)] do
          field name, type, address, len, access, desc, units: units, enum_map: enum_map
        end
      end)

    field_groups_ast = model_defs
      |> field_groupify()
      |> Enum.map(fn {name, fields} ->
        quote do
          field_group unquote(name), unquote(fields)
        end
      end)

    quote do
      use ExModbus
      unquote(fields_ast)
      unquote(field_groups_ast)
    end
  end

  defp setup_overrides(opts) do
    overrides = case Keyword.has_key?(opts, :overrides) do
      true ->
        {overrides, _} = Code.eval_quoted(opts[:overrides])
        overrides
      false -> %{}
    end

    overrides
    |> model_1_length(opts)
    |> models_path(opts)
  end

  defp model_1_length(overrides, opts) do
    model_1_length_65 = Keyword.get(opts, :model_1_length_65, false)
    case model_1_length_65 do
      true -> Map.merge(overrides, %{1 => %{length: 65}})
      false -> overrides
    end
  end

  defp models_path(overrides, opts) do
    case Keyword.get(opts, :models_path) do
      nil -> overrides
      model_paths -> Map.merge(overrides, %{model_paths: model_paths})
    end
  end
end
