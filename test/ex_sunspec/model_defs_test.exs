defmodule ExSunspec.ModeDefsTest do
  use ExUnit.Case
  alias ExSunspec.ModelDefs
  @root_dir File.cwd!
  @test_dir Path.join(@root_dir, "test")

  test "can parse xml into a model" do
    model = ModelDefs.load(1)

    assert model.name == "Common"
    assert model.length == 66
    assert model.desc == "All SunSpec compliant devices must include this as the first model"
    assert model.notes == ""

    # now test the 'points'
    assert Enum.count(model.points) == 6
    [mn | _rest] = model.points
    assert mn.id == "Mn"
    assert mn.offset == 0
    assert mn.type == "string"
    assert mn.len == 16
    assert mn.access == ""
    assert mn.name == "Manufacturer"
    assert mn.desc == "Well known value registered with SunSpec for compliance"
    assert mn.notes == ""

    da = model.points |> List.last
    assert da.id == "DA"
    assert da.offset == 64
    assert da.type == "uint16"
    assert da.access == "rw"
  end

  test "can override the model_defs folder" do
    model = ModelDefs.load(1, %{models_path: Path.join([@test_dir, "test_models"])})
    assert model.name == "Testing"
  end

  test "can override values" do
    model = ModelDefs.load(1, %{1 => %{length: 65}})
    assert model.length == 65
  end

  describe "can parse model 10 (pad)" do
    setup do
      {:ok, %{model: ModelDefs.load(10)}}
    end

    test "pad is ignored", %{model: model} do
      refute "Pad" == List.last(model.points)[:name]
    end
  end

  describe "can apply prefix to names" do
    setup do
      {:ok, %{model: ModelDefs.load({10, "jeff_"})}}
    end

    test "jeff_Interface Status is defined", %{model: model} do
      model[:points]
      |> Enum.any?(fn
        %{name: "jeff_Interface Status"} -> true
        _ -> false
      end)
      |> assert
    end

    test "jeff_Communication Interface Header is defined", %{model: model} do
      assert model[:name] == "jeff_Communication Interface Header"
    end
  end

  describe "can parse model 101" do
    setup do
      {:ok, %{model: ModelDefs.load(101)}}
    end

    test "scale factors", %{model: model} do
      aph_a = Enum.find(model.points, fn(pt) -> pt.id == "AphA" end)
      assert aph_a.sf == "A_SF"

      a_sf = Enum.find(model.points, fn(pt) -> pt.id == "A_SF" end)
      assert a_sf.name == "A_SF"
    end

    test "units", %{model: model} do
      aph_a = Enum.find(model.points, fn(pt) -> pt.id == "AphA" end)
      assert aph_a.units == "A"

      a_sf = Enum.find(model.points, fn(pt) -> pt.id == "A_SF" end)
      assert a_sf.units == ""
    end

    test "enumerations", %{model: model} do
      st = Enum.find(model.points, fn(pt) -> pt.id == "St" end)

      assert st.enum == %{
        1 => "OFF",
        2 => "SLEEPING",
        3 => "STARTING",
        4 => "MPPT",
        5 => "THROTTLED",
        6 => "SHUTTING_DOWN",
        7 => "FAULT",
        8 => "STANDBY",
      }

      evt1 = Enum.find(model.points, fn(pt) -> pt.id == "Evt1" end)
      assert evt1.enum == %{
        0 => "GROUND_FAULT",
        1 => "DC_OVER_VOLT",
        2 => "AC_DISCONNECT",
        3 => "DC_DISCONNECT",
        4 => "GRID_DISCONNECT",
        5 => "CABINET_OPEN",
        6 => "MANUAL_SHUTDOWN",
        7 => "OVER_TEMP",
        8 => "OVER_FREQUENCY",
        9 => "UNDER_FREQUENCY",
        10 => "AC_OVER_VOLT",
        11 => "AC_UNDER_VOLT",
        12 => "BLOWN_STRING_FUSE",
        13 => "UNDER_TEMP",
        14 => "MEMORY_LOSS",
        15 => "HW_TEST_FAILURE",
      }
    end
  end
end

