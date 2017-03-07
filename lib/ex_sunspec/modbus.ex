defmodule ExSunspec.Modbus do
  def fieldify([], _, acc), do: acc
  def fieldify([model | rest], start, acc) do
    # IO.puts inspect "Starting point for #{model.name} is #{start + 2}"
    acc = model.points
    |> Enum.filter(&include?/1)
    |> Enum.reduce(acc, fn(field_struct, acc) ->
      acc ++ [to_field(start, field_struct)]
    end)
    # IO.puts inspect [start, model.length]
    fieldify(rest, start + model.length + 2, acc)
  end

  def to_field(start, field) do
    # IO.puts inspect ["--", start + field.offset + 2, get_name(field.name)]
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

  def include?(%{name: nil}), do: false
  def include?(%{name: ""}), do: false
  def include?(%{name: _}), do: true

  def get_name(nil), do: nil
  def get_name(name) do
    name
    |> String.downcase
    |> String.split(" ")
    |> Enum.join("_")
    |> String.to_atom
  end

  def get_type(type) when is_atom(type), do: type
  def get_type(type), do: String.to_atom(type)

  def get_length(nil, "sunssf"), do: 1
  def get_length(nil, type) when is_atom(type), do: get_length(nil, Atom.to_string(type))
  def get_length(nil, type) do
    case Regex.run(~r"\d+$", type) do
      nil -> raise "Could not determine length of type: #{type}"
      [len] -> (len |> String.to_integer) / 16
    end
  end
  def get_length(len, _), do: len

  def get_access(""), do: :r
  def get_access(nil), do: :r
  def get_access(access) when is_atom(access), do: access
  def get_access(access), do: String.to_atom(access)
end
