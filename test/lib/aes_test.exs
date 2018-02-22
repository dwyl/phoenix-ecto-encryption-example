defmodule Encryption.AESTest do
  use ExUnit.Case
  alias Encryption.AES

  doctest Encryption.AES

  test ".encrypt can encrypt a value" do
    assert AES.encrypt("hello") != "hello"
  end

  test ".encrypt includes the random IV in the value" do
    <<iv::binary-16, ciphertext::binary>> = AES.encrypt("hello")

    assert String.length(iv) != 0
    assert String.length(ciphertext) != 0
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

  test "can decrypt_gcm a value" do
    keys = Application.get_env(:encryption, Encryption.AES)[:keys]
    key_id = Enum.count(keys) - 1
    IO.inspect key_id, label: "key_id"
    ciphertext = AES.encrypt_gcm("hello", key_id)
    IO.inspect ciphertext, label: "ciphertext"
    # plaintext = "hello" |> AES.encrypt_gcm |> AES.decrypt_gcm(key_id)
    plaintext = AES.decrypt_gcm(ciphertext, key_id)
    IO.inspect plaintext, label: "plaintext"
    assert plaintext == "hello"
  end

  test "can decrypt_gcm with default key" do
    plaintext = "hello" |> AES.encrypt_gcm |> AES.decrypt_gcm()
    assert plaintext == "hello"
  end
end
