# Plug Protobufs

A plug parser for Protobufs input. This creates a simple and easy way to accept Protobufs as the input to your plug projects.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `plug_protobufs` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:plug_protobufs, "~> 0.1.1"}]
    end
    ```

  2. Add `Plug.Parsers.Protobuf` to your Plug parsers:

    ```elixir
    config :plug, :parsers, [Plug.Parsers.Protobuf]
    ```

    or add the plug yourself:

    ```elixir
    plug Plug.Parsers,
      parsers: [Plug.Parsers.Protobuf]
    ```

  3. Define your Protobufs:

    ```elixir
    defmodule Requests do
      use Protobufs, """
      message HelloRequest {
        string name = 1;
      }
      message HelloResponse {
        string greeting = 1;
      }
      """
    end
    ```

  3. In your route handler, add:

    ```elixir
    defmodule AppRouter do
      use Plug.Router

      get "/hello", private: %{protobuf: Requests.HelloRequest} do
        send_resp(conn, 200, "hello #{conn.params["_protobuf"].name}")
      end
    end
    ```

    or, if you want to response in protobufs:

    ```elixir
    defmodule AppRouter do
      use Plug.Router

      get "/hello", private: %{protobuf: Requests.HelloRequest} do
        name = conn.params["_protobuf"].name

        conn
          |> put_resp_content_type("application/x-protobuf")
          |> send_resp(200, Requests.HelloResponse.new(greeting: "Hello #{name}"))
      end
    end
    ```
