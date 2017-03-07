defmodule ExSunspec.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_sunspec,
     version: "0.1.0",
     elixir: "~> 1.4",
     elixirrc_paths: elixirc_paths(Mix.env),
     description: "An Elixir SunSpec client implementation",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),

     name: "ExSunSpec",
     source_url: "https://github.com/jeffdeville/ex_sunspec",
     homepage_url: "https://github.com/jeffdeville/ex_sunspec",
     docs: [main: "ExSunSpec",
            logo: "sunspec_logo.png",
            extras: ["README.md"]]
    ]
  end

  def package do
    [
      maintainers: ["Jeff Deville"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/jeffdeville/ex_sunspec"}
    ]
  end
  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:ex_modbus, github: "jeffdeville/ex_modbus", branch: "tcp-tests" },
     {:ex_doc, "~> 0.14.5", only: :dev},
     {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
     {:sweet_xml, "~> 0.6.5", runtime: false},
     {:credo, "~> 0.6", only: [:dev, :test]},
    ]
  end
end
