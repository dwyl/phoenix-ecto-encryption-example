defmodule Encryption.PasswordFieldTest do
  use ExUnit.Case
  alias Encryption.PasswordField, as: Type # our Ecto Custom Type

  test ".type is :binary" do
    assert Type.type == :binary
  end

  test ".cast converts a value to a string" do
    assert {:ok, "42"} == Type.cast(42)
    assert {:ok, "atom"} == Type.cast(:atom)
  end

  test ".dump returns an Argon2id Hash given a password string" do
    {:ok, result} = Type.dump("password")
    # IO.inspect result, label: "result"
    assert is_binary(result)
    assert String.starts_with?(result, "$argon2id$v=19$m=256,t=1,p=1$")
  end

  test ".load does not modify the hash, since the hash cannot be reversed" do
    hash = Type.hash("password")
    assert {:ok, ^hash} = Type.load(hash)
  end

  test ".check checks the password against the Argon2id Hash" do
    password = "EverythingisAwesome"
    hash = Type.hash(password)
    verified = Type.verify_pass(password, hash)
    # IO.inspect verified, label: "verified"
    assert verified
  end

  test ".verify_pass fails if password does NOT match hash" do
    password = "EverythingisAwesome"
    hash = Type.hash(password)
    verified = Type.verify_pass("LordBusiness", hash)
    # IO.inspect verified, label: "verified"
    assert !verified
  end
end
