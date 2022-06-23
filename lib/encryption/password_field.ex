defmodule Encryption.PasswordField do
  @behaviour Ecto.Type

  def type, do: :binary

  def cast(value) do
    {:ok, to_string(value)}
  end

  def dump(value) do
    {:ok, hash_password(value)}
  end

  def load(value) do
    {:ok, value}
  end

  def embed_as(_), do: :self

  def equal?(value1, value2), do: value1 == value2

  def hash_password(value) do
    Argon2.Base.hash_password(to_string(value),
      Argon2.gen_salt(), [{:argon2_type, 2}])
  end

  def verify_password(password, stored_hash) do
    Argon2.verify_pass(password, stored_hash)
  end
end
