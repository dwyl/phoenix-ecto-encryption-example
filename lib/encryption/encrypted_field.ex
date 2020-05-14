defmodule Encryption.EncryptedField do
  # alias our AES encrypt & decrypt functions (3.1 & 3.2)
  alias Encryption.AES

  # Check this module conforms to Ecto.type behavior.
  @behaviour Ecto.Type
  # :binary is the data type ecto uses internally
  def type, do: :binary

  # cast/1 simply calls to_string on the value and returns a "success" tuple
  def cast(value) do
    {:ok, to_string(value)}
  end

  # dump/1 is called when the field value is about to be written to the database
  def dump(value) do
    ciphertext = value |> to_string |> AES.encrypt()
    # ciphertext is :binary type (no conversion required)
    {:ok, ciphertext}
  end

  # load/1 is called when the field is loaded from the database
  def load(value) do
    {:ok, AES.decrypt(value)}
  end

  # embed_as/1 dictates how the type behaves when embedded (:self or :dump)
  # preserve the type's higher level representation
  def embed_as(_), do: :self

  # equal?/2 is called to determine if two field values are semantically equal
  def equal?(value1, value2), do: value1 == value2
end
