defmodule ExSunspec.Modbus do
  @spec fieldify(list(), integer(), list()) :: list()
  def fieldify([], _, acc), do: acc
  def fieldify([model | rest], start, acc) do
    acc = model.points
    |> Enum.filter(&include?/1)
    |> Enum.reduce(acc, fn(field_struct, acc) ->
      acc ++ [to_field(start, field_struct)]
    end)
    fieldify(rest, start + model.length + 2, acc)
  end

  @spec field_groupify(list(map())) :: list(tuple())
  def field_groupify(models) do
    models
    |> Enum.map(fn model ->
      name = get_name(model.name)
      fields = model.points
        |> Enum.map(&(&1.name))
        |> Enum.map(&get_name/1)
        |> Enum.reject(&(&1 == :""))
      {name, fields}
    end)
  end

  @type field_data :: {atom, atom, integer, integer, atom, String.t, String.t, map}
  @spec to_field(integer(), map()) :: field_data
  def to_field(start, field) do
    {
      get_name(field.name),
      get_type(field.type),
      start + field.offset + 2,
      get_length(field.len, field.type),
      get_access(field.access),
      field.desc,
      field.units,
      field.enum
    }
  end

  @spec include?(%{name: String.t | nil}) :: boolean
  def include?(%{name: nil}), do: false
  def include?(%{name: ""}), do: false
  def include?(%{name: _}), do: true

  @spec get_name(String.t | nil) :: String.t | nil
  def get_name(nil), do: nil
  def get_name(name) do
    name
    |> String.downcase
    |> String.replace("(", "")
    |> String.replace(")", "")
    |> String.split(" ")
    |> Enum.join("_")
    |> String.to_atom
  end

  @spec get_type(atom | String.t) :: atom
  def get_type(type) when is_atom(type), do: type
  def get_type(type), do: String.to_atom(type)

  @spec get_length(integer | nil, String.t | atom) :: integer
  def get_length(nil, "sunssf"), do: 1
  def get_length(nil, type) when is_atom(type), do: get_length(nil, Atom.to_string(type))
  def get_length(nil, type) do
    case Regex.run(~r"\d+$", type) do
      nil -> raise "Could not determine length of type: #{type}"
      [len] -> round((len |> String.to_integer) / 16)
    end
  end
  def get_length(len, _), do: len

  @spec get_access(String.t | nil | atom) :: atom
  def get_access(""), do: :r
  def get_access(nil), do: :r
  def get_access(access) when is_atom(access), do: access
  def get_access(access), do: String.to_atom(access)
end
