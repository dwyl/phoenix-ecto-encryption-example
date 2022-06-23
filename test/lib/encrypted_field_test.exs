defmodule Encryption.EncryptedFieldTest do
  use ExUnit.Case
  alias Encryption.EncryptedField, as: Field

  test ".type is :binary" do
    assert Field.type() == :binary
  end

  test ".cast converts a value to a string" do
    assert {:ok, "123"} == Field.cast(123)
  end

  test ".dump encrypts a value" do
    {:ok, ciphertext} = Field.dump("hello")

    assert ciphertext != "hello"
    assert String.length(ciphertext) != 0
  end
end
