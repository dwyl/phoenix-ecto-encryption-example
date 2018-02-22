defmodule Encryption.HashFieldTest do
  use ExUnit.Case
  alias Encryption.HashField, as: Type # our Ecto Custom Type for hashed fields

  test ".type is :binary" do
    assert Type.type == :binary
  end

  test ".cast converts a value to a string" do
    assert {:ok, "42"} == Type.cast(42)
    assert {:ok, "atom"} == Type.cast(:atom)
  end

  test ".dump converts a value to a sha256 hash" do
    {:ok, hash} = Type.dump("hello")
    assert hash == <<16, 231, 67, 229, 9, 181, 13, 87, 69, 76, 227, 205, 43,
              124, 16, 75, 46, 161, 206, 219, 141, 203, 199, 88, 112, 1, 204,
              189, 109, 248, 22, 254>>
  end

  test ".hash converts a value to a sha256 hash with secret_key_base as salt" do
    hash = Type.hash("test@example.com")
    assert hash == <<182, 127, 234, 116, 164, 190, 231, 177, 209, 10, 34, 171,
              87, 22, 175, 205, 130, 244, 106, 188, 213, 62, 90, 24, 5, 163,
              125, 76, 65, 181, 167, 181>>
  end

  test ".load does not modify the hash, since the hash cannot be reversed" do
    hash = <<16, 231, 67, 229, 9, 181, 13, 87, 69, 76, 227, 205, 43, 124, 16,
              75, 46, 161, 206, 219, 141, 203, 199, 88, 112, 1, 204, 189, 109,
              248, 22, 254>>
    assert {:ok, ^hash} = Type.load(hash)
  end
end
