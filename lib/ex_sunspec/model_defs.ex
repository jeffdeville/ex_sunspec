defmodule ExSunspec.ModelDefs do
  import SweetXml

  @spec load(number | {number, String.t}, %{}) :: ExSunspec.Model.t
  def load(model_num, overrides \\ %{})
  def load(model_num, overrides) when is_number(model_num) do
    model_num
    |> load_xml(overrides)
    |> build_model_def
    |> Map.merge(Map.get(overrides, model_num, %{}))
  end
  def load({model_num, prefix}, overrides) do
    model_num
    |> load(overrides)
    |> apply_prefix(prefix)
  end

  @spec load_xml(number, map()) :: String.t
  defp load_xml(model_num, overrides) do
    file_portion = model_num |> Integer.to_string |> String.pad_leading(5, "0")
    default_path = Path.join([:code.priv_dir(:ex_sunspec), "sunspec_models", "smdx"])
    paths = case overrides do
      %{models_path: models_path} -> [models_path, default_path]
      _ -> [default_path]
    end

    file = paths
      |> Enum.map(&(Path.join([&1, "smdx_#{file_portion}.xml"])))
      |> Enum.find(&(File.exists?(&1)))
    case file do
      nil -> raise ArgumentError, "Model file #{model_num} not found"
      path -> File.read!(path)
    end
  end

  @spec build_model_def(String.t) :: map
  defp build_model_def(xml) do
    raw_model = xml
    |> xmap(
      id: ~x"//model/@id"i,
      name: ~x"//strings/model/label/text()"s,
      length: ~x"//model/@len"i,
      desc: ~x"//strings/model/description/text()"s,
      notes: ~x"//strings/model/notes/text()"s,
      points: [
        ~x"//model/block/point"l,
        id: ~x"./@id"s,
        offset: ~x"./@offset"i,
        type: ~x"./@type"s,
        len: ~x"./@len"oi,
        access: ~x"./@access"s,
        sf: ~x"./@sf"s,
        units: ~x"./@units"s,
        enum: [
          ~x"./symbol"l,
          value: ~x"./@id"s,
          id: ~x"./text()"i
        ]
      ]
    )

    model = Map.put(raw_model, :points, mapify_point_enums(raw_model.points))

    docs = xml |> xpath(
      ~x"//strings/point"l,
      id: ~x"./@id"s,
      name: ~x"./label/text()"s,
      desc: ~x"./description/text()"s,
      notes: ~x"./notes/text()"s
    )

    points = model.points
    |> Enum.map(fn(pt) ->
      doc = case Enum.find(docs, fn(d) -> d.id == pt.id end) do
        nil -> %{name: pt.id, desc: "Scale Factor"}
        doc -> doc
      end
      %{}
      |> Map.merge(pt)
      |> Map.merge(doc)
    end)
    |> Enum.reject(fn(pt) -> pt.name == "" end)
    |> Enum.reject(fn(pt) -> pt.name == "Pad" end)
    |> Enum.map(fn (pt) -> %{pt | name: "#{model[:name]} #{pt[:name]}"} end)

    %{model | points: points}
  end

  defp mapify_point_enums(points) do
    points
    |> Enum.map(&mapify_enums/1)
  end

  defp mapify_enums(%{enum: nil} = point), do: point
  defp mapify_enums(%{enum: enums} = point) do
    enums = enums
    |> Enum.reduce(%{}, fn(%{id: id, value: val}, acc) ->
      Map.put(acc, id, val)
    end)
    Map.put(point, :enum, enums)
  end

  defp apply_prefix(model, prefix) when is_map(model),
    do: %{model | name: prefix <> model[:name], points: apply_prefix(model[:points], prefix)}
  defp apply_prefix(points, prefix) when is_list(points) do
    Enum.map(points, fn %{name: name} = point -> %{point | name: prefix <> name} end)
  end
end
