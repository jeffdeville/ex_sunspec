defmodule ExSunspec.TestInverter do
  use ExSunspec, start: 40_001,
                 models: [1, 101, 120, 121, 122, 123],
                 model_1_length_65: true
  field :delete_data, :uint16, 212, 1, :rw, "Delete stored ratings of the current inverter by writing 0xFFFF"
  field :store_data, :uint16, 213, 1, :rw, "Rating data of all inverters connected to the Fronius Datamanager are persistently stored by writing 0xFFFF."
  field :active_state_code, :uint16, 214, 1, :r, "Current active state code of inverter - Description can be found in inverter manual"
  field :reset_event_flags, :uint16, 215, 1, :rw, "Write 0xFFFF to reset all event flags and active state code."
  field :model_type, :uint16, 216, 1, :rw, "Type of SunSpec models used for inverter and meter data. Write 1 or 2 and then immediately 6 to acknowledge setting.", enum_map: %{1 => "Floating point", 2 => "Integer & SF"}
end

defmodule ExSunSpecTest do
  use ExUnit.Case
  alias ExSunspec.TestInverter

  defp get_field_addr(name) do
    {_, _, address, _, _, _, _, _} = get_field(name)
    address
  end

  defp get_field_perms(name) do
    {_, _, _, _, perms, _, _, _} = get_field(name)
    perms
  end

  defp get_field_enums(name) do
    {_, _, _, _, _, _, _, enum} = get_field(name)
    enum
  end

  def get_field(name) do
    TestInverter.field_defs()
    |> Enum.find(fn(val) ->
      case val do
        {^name, _, _, _, _, _, _, _} -> true
        _ -> false
      end
    end)
  end

  test "fields are defined" do
    funcs = TestInverter.__info__(:functions)
    assert Keyword.has_key?(funcs, :manufacturer)
    assert Keyword.has_key?(funcs, :model)
    assert Keyword.has_key?(funcs, :options)
    assert Keyword.has_key?(funcs, :version)
    assert Keyword.has_key?(funcs, :serial_number)
    assert Keyword.has_key?(funcs, :device_address)

    # Model 1
    assert get_field_addr(:manufacturer) == 40_005

    # Model 101
    assert get_field_addr(:amps) == 40_072
    assert get_field_addr(:operating_state) == 40_108
    assert get_field_addr(:vendor_event_bitfield_4) == 40_120

    # Model 120
    assert get_field_addr(:dertyp) == 40_124
    assert get_field_addr(:whrtg) == 40_141

    # Model 120
    assert get_field_addr(:dertyp) == 40_124
    assert get_field_addr(:whrtg) == 40_141
  end

  test "custom fields are defined" do
    funcs = TestInverter.__info__(:functions)
    assert Keyword.has_key?(funcs, :model_type)
    assert get_field_addr(:model_type) == 216
  end

  test "writable fields are defined" do
    assert get_field_perms(:manufacturer) == :r
    assert get_field_perms(:conn_wintms) == :rw
  end

  test "enumerated fields are handled" do
    assert get_field_enums(:operating_state) == %{1 => "OFF", 2 => "SLEEPING", 3 => "STARTING", 4 => "MPPT", 5 => "THROTTLED", 6 => "SHUTTING_DOWN", 7 => "FAULT", 8 => "STANDBY"}
  end
end
