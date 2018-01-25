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
    plaintext = "hello" |> AES.encrypt |> AES.decrypt
    assert plaintext == "hello"
  end
end
