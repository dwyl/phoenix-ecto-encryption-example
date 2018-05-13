defmodule Encryption.EncryptedFieldTest do
  use ExUnit.Case
  alias Encryption.EncryptedField, as: Field

  test ".type is :binary" do
    assert Field.type == :binary
  end

  test ".cast converts a value to a string" do
    assert {:ok, "123"} == Field.cast(123)
  end

  test ".dump encrypts a value" do
    {:ok, ciphertext} = Field.dump("hello")

    assert ciphertext != "hello"
    assert String.length(ciphertext) != 0
  end

  test ".load decrypts a value" do
    {:ok, ciphertext} = Field.dump("hello")
    keys = Application.get_env(:encryption, Encryption.AES)[:keys]
    key_id = Enum.count(keys) - 1
    assert {:ok, "hello"} == Field.load(ciphertext, key_id)
  end
end
