# ExSunspec

ExSunSpec lets you quickly define profiles for SunSpec compliant devices.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_sunspec` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:ex_sunspec, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_sunspec](https://hexdocs.pm/ex_sunspec).

## Use

ExSunSpec uses macros to let you define unit profiles with minimal data declaration. Example:

### Declare 

```elixir
defmodule ExSunspec.Profile.Fronius do
  use ExModbus.SunSpec
  
  # You can define your mappings in a CSV, or inline in your model 
  # declarations. If you use a csv, just remember to set the 
  # @external_resource value, so that changes to your csv will trigger a 
  # recompilation of your model!
  @external_resource Path.join([__DIR__, "model_1.csv"])
  model 1, length: 65, Path.join([__DIR__, "model_1.csv"])
  
  model 101, length: 50, [
    {40_003, :uint16, :r, :ac_total_current, "(A, amps) AC Total Current value"},
    {40_004, :uint16, :r, :ac_phase_a_current, "(AphA, amps) AC Phase-A Current value"},
  ]
  model 123
end
```



### Read Data

```
alias ExSunspec.Profile.Fronius
{:ok, pid} = Fronius.start_link {10, 0, 0, 1}
Fronius.mn(pid, 1)
{:ok, "Fronius"}
```

### Write Data
```
alias ExSunspec.Profile.Fronius
{:ok, pid} = Fronius.start_link {10, 0, 0, 1}
Fronius.set_out_pfset(pid, 1, 12)
{:ok, 12}
```
