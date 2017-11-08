defmodule PlugProtobufs.Mixfile do
  use Mix.Project

  def project do
    [app: :plug_protobufs,
     version: "0.1.0",
     elixir: "~> 1.3",
     description: description(),
     package: package(), 
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:plug, "~> 1.4.3"},
      {:protobufex, github: "hayesgm/protobuf-elixir", branch: "hayesgm/extensions-ex"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    A plug parser for Protobufs input. This creates a simple and easy way to accept Protobufs as the input to your plug projects.
    """
  end

  defp package do
    [
      maintainers: ["Geoffrey Hayes", "Fahim Zahur"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/hayesgm/plug_protobufs"}
    ]
  end
end
