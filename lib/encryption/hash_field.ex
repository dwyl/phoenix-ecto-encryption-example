defmodule Encryption.HashField do
  @behaviour Ecto.Type

  def type, do: :binary

  def cast(value) do
    {:ok, to_string(value)}
  end

  def dump(value) do
    {:ok, hash(value)}
  end

  def load(value) do
    {:ok, value}
  end

  def hash(value) do
    :crypto.hash(:sha256, value <> get_salt())
  end

  defp get_salt do
    Application.get_env(:encryption, EncryptionWeb.Endpoint)[:secret_key_base]
  end
end
