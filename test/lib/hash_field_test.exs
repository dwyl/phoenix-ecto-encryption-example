defmodule Encryption.HashFieldTest do
  use ExUnit.Case
  alias Encryption.HashField, as: Field # our Ecto Custom Type for hashed fields

  test ".type is :binary" do
    assert Field.type == :binary
  end

  test ".cast converts a value to a string" do
    assert {:ok, "42"} == Field.cast(42)
    assert {:ok, "atom"} == Field.cast(:atom)
  end

  test ".dump converts a value to a sha256 hash" do
    {:ok, hash} = Field.dump("hello")
    assert hash == <<12, 25, 78, 36, 26, 203, 166, 213, 129, 193, 199, 22, 51,
                    10, 239, 208, 6, 222, 237, 9, 12, 197, 118, 96, 149, 176,
                    40, 4, 95, 241, 219, 112>>
  end

  test ".hash converts a value to a sha256 hash with secret_key_base as salt" do
    hash = Field.hash("alex@example.com")
    assert hash == <<74, 63, 196, 137, 191, 105, 153, 76, 235, 10, 244, 55,
                    153, 170, 114, 88, 70, 219, 118, 187, 190, 91, 169, 181,
                    140, 24, 79, 133, 247, 228, 115, 220>>
  end

  test ".load does not modify the hash, since the hash cannot be reversed" do
    hash = <<16, 231, 67, 229, 9, 181, 13, 87, 69, 76, 227, 205, 43, 124, 16,
              75, 46, 161, 206, 219, 141, 203, 199, 88, 112, 1, 204, 189, 109,
              248, 22, 254>>
    assert {:ok, ^hash} = Field.load(hash)
  end

  test ".equal? correctly determines hash equality and inequality" do
    hash1 = <<16, 231, 67, 229, 9, 181, 13, 87, 69, 76, 227, 205, 43, 124, 16,
              75, 46, 161, 206, 219, 141, 203, 199, 88, 112, 1, 204, 189, 109,
              248, 22, 254>>
    hash2 = <<10, 231, 67, 229, 9, 181, 13, 87, 69, 76, 227, 205, 43, 124, 16,
              75, 46, 161, 206, 219, 141, 203, 199, 88, 112, 1, 204, 189, 109,
              248, 22, 254>>
    assert Field.equal?(hash1, hash1)
    refute Field.equal?(hash1, hash2)
  end
end
