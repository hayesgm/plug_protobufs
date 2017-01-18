defmodule PlugProtobufs.ProtobufTest do
  use ExUnit.Case, async: true

  defmodule Person do
    use Protobuf, """
      message Person {
      required string name = 1;
      required int32 id = 2;
      optional string email = 3;
    }
    """
  end

  @bin <<10,7,97,98,99,32,100,
    101,102,16,217,2,26,13,97,64,101,
    120,97,109,112,108,101,46,99,111,109>>

  test "given a simple protobuf body" do
    conn = %Plug.Conn{
      req_headers: [{"content-type", "application/x-protobuf"}],
      private: %{protobuf: Person.Person},
    } |> Plug.Adapters.Test.Conn.conn("POST", "/abc", @bin)

    opts = Plug.Parsers.init(parsers: [Plug.Parsers.Protobuf])
    conn = Plug.Parsers.call(conn, opts)

    assert conn.params["_protobuf"] == %PlugProtobufs.ProtobufTest.Person.Person{
      email: "a@example.com",
      id: 345,
      name: "abc def"
    }
  end

  test "given a simple protobuf body alt content type" do
    conn = %Plug.Conn{
      req_headers: [{"content-type", "application/octet-stream+protobuf"}],
      private: %{protobuf: Person.Person},
    } |> Plug.Adapters.Test.Conn.conn("POST", "/abc", @bin)

    opts = Plug.Parsers.init(parsers: [Plug.Parsers.Protobuf])
    conn = Plug.Parsers.call(conn, opts)

    assert conn.params["_protobuf"] == %PlugProtobufs.ProtobufTest.Person.Person{
      email: "a@example.com",
      id: 345,
      name: "abc def"
    }
  end

  test "given a blank body" do
    conn = %Plug.Conn{
      req_headers: [{"content-type", "application/x-protobuf"}],
      private: %{protobuf: Person.Person},
    } |> Plug.Adapters.Test.Conn.conn("POST", "/abc", "")

    opts = Plug.Parsers.init(parsers: [Plug.Parsers.Protobuf])
    conn = Plug.Parsers.call(conn, opts)

    assert conn.params["_protobuf"] == %PlugProtobufs.ProtobufTest.Person.Person{
      email: "",
      id: 0,
      name: ""
    }
  end

  test "given a nil body" do
    conn = %Plug.Conn{
      req_headers: [{"content-type", "application/x-protobuf"}],
      private: %{protobuf: Person.Person},
    } |> Plug.Adapters.Test.Conn.conn("POST", "/abc", nil)

    opts = Plug.Parsers.init(parsers: [Plug.Parsers.Protobuf])
    conn = Plug.Parsers.call(conn, opts)

    assert conn.params["_protobuf"] == %PlugProtobufs.ProtobufTest.Person.Person{
      email: "",
      id: 0,
      name: ""
    }
  end

  test "given a bad body" do
    conn = %Plug.Conn{
      req_headers: [{"content-type", "application/x-protobuf"}],
      private: %{protobuf: Person.Person},
    } |> Plug.Adapters.Test.Conn.conn("POST", "/abc", "abc")

    opts = Plug.Parsers.init(parsers: [Plug.Parsers.Protobuf])

    assert_raise Plug.Parsers.ParseError, fn ->
      Plug.Parsers.call(conn, opts)
    end
  end

  test "given no decoder" do
    conn = %Plug.Conn{
      req_headers: [{"content-type", "application/x-protobuf"}],
    } |> Plug.Adapters.Test.Conn.conn("POST", "/abc", "abc")

    opts = Plug.Parsers.init(parsers: [Plug.Parsers.Protobuf])

    assert_raise CaseClauseError, fn ->
      Plug.Parsers.call(conn, opts)
    end
  end

  test "given different content type" do
    conn = %Plug.Conn{
      req_headers: [{"content-type", "application/x-www-form-urlencoded"}],
      private: %{protobuf: Person.Person},
    } |> Plug.Adapters.Test.Conn.conn("POST", "/abc", "a=b")

    opts = Plug.Parsers.init(parsers: [Plug.Parsers.Protobuf, :urlencoded])
    conn = Plug.Parsers.call(conn, opts)

    assert conn.params == %{"a" => "b"}
  end
end