defmodule Plug.Parsers.Protobuf do
  @moduledoc """
  Parses a Protobuf request body.

  The router definition must set a `private: MyProtobuf` field
  so that we know which protobuf definition to use to parse the
  protobuf.
  """

  @behaviour Plug.Parsers
  import Plug.Conn

  def parse(conn, "application", subtype, _headers, opts) do
    if subtype == "x-protobuf" || String.ends_with?(subtype, "+protobuf") do
      case conn.private[:protobuf] || conn.private[:req] do
        nil -> {:error, :no_protobuf_in_private, conn}
        protobuf ->
          conn
          |> read_body(opts)
          |> decode(protobuf)
      end
    else
      {:next, conn}
    end
  end

  def parse(conn, _type, _subtype, _headers, _opts) do
    {:next, conn}
  end

  defp decode({:more, _, conn}, _protobuf) do
    {:error, :too_large, conn}
  end

  defp decode({:error, :timeout}, _protobuf) do
    raise Plug.TimeoutError
  end

  defp decode({:error, _}, _protobuf) do
    raise Plug.BadRequestError
  end

  defp decode({:ok, body, conn}, protobuf) do

    {:ok, %{"_protobuf" => protobuf.decode(body)}, conn}
  rescue
    e -> raise Plug.Parsers.ParseError, exception: e
  end
end
