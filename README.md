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
defmodule Fronius.SpecificModel do
  use ExModbus.SunSpec, 40_000, [100, 101, 121, 133]
end
```

### Usage TCP and RTU

ex_sunspec relies on ex_modbus, which can communicate via TCP or RTU connections. The connection required is inferred based on the start_link parameters.  If a host or ip is provided, we assume TCP. If tty & speed are provided, then RTU is configured.

### Read Data

```
{:ok, pid} = Fronius.SpecificModel.start_link {10, 0, 0, 1}
Fronius.mn(pid, 1)
{:ok, "Fronius"}
```

### Write Data
```
{:ok, pid} = Fronius.SpecificModel.start_link {10, 0, 0, 1}
Fronius.SpecificModel.set_out_pfset(pid, 1, 12)
{:ok, 12}
```
