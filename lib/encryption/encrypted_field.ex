defmodule Encryption.EncryptedField do
  alias Encryption.AES

  @behaviour Ecto.Type

  def type, do: :binary

  def cast(value) do
    {:ok, to_string(value)}
  end

  def dump(value) do
    ciphertext = value |> to_string |> AES.encrypt
    {:ok, ciphertext}
  end

  def load(value) do
    {:ok, AES.decrypt(value)}
  end
end
