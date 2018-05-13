defmodule Encryption.AESTest do
  use ExUnit.Case
  alias Encryption.AES

  doctest Encryption.AES

  test ".encrypt can encrypt a value" do
    assert AES.encrypt("hello") != "hello"
  end

  test ".encrypt can encrypt a number" do
    assert is_binary(AES.encrypt(123, 1))
  end

  test ".encrypt includes the random IV in the value" do
    <<iv::binary-16, ciphertext::binary>> = AES.encrypt("hello")

    assert String.length(iv) != 0
    assert String.length(ciphertext) != 0
    assert is_binary(ciphertext)
  end

  test ".encrypt does not produce the same ciphertext twice" do
    assert AES.encrypt("hello") != AES.encrypt("hello")
  end

  test "can decrypt a value" do
    keys = Application.get_env(:encryption, Encryption.AES)[:keys]
    key_id = Enum.count(keys) - 1
    plaintext = "hello" |> AES.encrypt |> AES.decrypt(key_id)
    assert plaintext == "hello"
  end

  test "can decrypt/2 a value" do
    keys = Application.get_env(:encryption, Encryption.AES)[:keys]
    key_id = Enum.count(keys) - 1
    ciphertext = AES.encrypt("hello", key_id)
    plaintext = AES.decrypt(ciphertext, key_id)
    assert plaintext == "hello"
  end

  test "decrypt/1 ciphertext that was encrypted with default key" do
    plaintext = "hello" |> AES.encrypt |> AES.decrypt()
    assert plaintext == "hello"
  end
end
