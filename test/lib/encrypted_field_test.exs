defmodule Encryption.EncryptedFieldTest do
  use ExUnit.Case
  alias Encryption.EncryptedField, as: Type

  test ".type is :binary" do
    assert Type.type == :binary
  end

  test ".cast converts a value to a string" do
    assert {:ok, "123"} == Type.cast(123)
  end

  test ".dump encrypts a value" do
    {:ok, ciphertext} = Type.dump("hello")

    assert ciphertext != "hello"
    assert String.length(ciphertext) != 0
  end

  test ".load decrypts a value" do
    {:ok, ciphertext} = Type.dump("hello")
    assert {:ok, "hello"} == Type.load(ciphertext)
  end
end
