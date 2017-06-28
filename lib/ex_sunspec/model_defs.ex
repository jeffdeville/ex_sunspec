defmodule ExSunspec.ModelDefs do
  import SweetXml

  @spec load(number, %{}) :: ExSunspec.Model.t
  def load(model_num, overrides \\ %{}) do
    models_path = Map.get(overrides, :models_path, Path.join([:code.priv_dir(:ex_sunspec), "sunspec_models", "smdx"]))
    model_num
    |> load_xml(models_path)
    |> build_model_def
    |> Map.merge(Map.get(overrides, model_num, %{}))
  end

  @spec load_xml(number, String.t()) :: String.t
  defp load_xml(model_num, models_path) do
    file_portion = model_num |> Integer.to_string |> String.pad_leading(5, "0")
    path = Path.join([models_path, "smdx_#{file_portion}.xml"])
    File.read!(path)
  end

  @spec build_model_def(String.t) :: map
  defp build_model_def(xml) do
    raw_model = xml
    |> xmap(
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

    Map.put(model, :points, points)
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
end
