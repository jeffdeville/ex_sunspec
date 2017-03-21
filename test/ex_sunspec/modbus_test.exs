defmodule ExSunspec.FieldTest do
  use ExUnit.Case
  import ExSunspec.Modbus

  test "exclude names that are nil" do
    assert include?(%{name: nil}) == false
    assert include?(%{name: "jeff"}) == true
  end

  test "to_field/2" do
    field = %{
      name: "Name Value",
      type: "type",
      offset: 10,
      len: 2,
      access: "r",
      desc: "desc",
      units: "units",
      notes: nil,
      sf: nil,
      enum: %{}
    }

    assert to_field(40_000, field) == {:name_value, :type, 40_012, 2, :r, "desc", "units", %{}}

    field = Map.put(field, :access, nil)
    assert to_field(40_000, field) == {:name_value, :type, 40_012, 2, :r, "desc", "units", %{}}
  end

  test "get_name/1" do
    assert get_name(nil) == nil
    assert get_name("hi_there") == :hi_there
    assert get_name("Hi There") == :hi_there
  end

  test "get_type/1" do
    assert get_type("type") == :type
    assert get_type(:type) == :type
  end

  test "get_access/1" do
    assert get_access(nil) == :r
    assert get_access("") == :r
    assert get_access("r") == :r
    assert get_access("rw") == :rw
    assert get_access(:rw) == :rw
  end

  describe "get_length/2" do
    test "when length is provided" do
      assert get_length(14, "string") == 14
    end

    test "when type is sunssf" do
      assert get_length(nil, "sunssf") == 1
      assert get_length(nil, :sunssf) == 1
    end

    test "when type is int16" do
      assert get_length(nil, "int16") == 1
      assert get_length(nil, :int16) == 1
    end

    test "when type is int32" do
      assert get_length(nil, "int32") == 2
      assert get_length(nil, :int32) == 2
    end

    test "when type is float32" do
      assert !is_float(get_length(nil, "float32"))
      assert !is_float(get_length(nil, :float32))
      assert get_length(nil, "float32") == 2
      assert get_length(nil, :float32) == 2
    end
  end
end
