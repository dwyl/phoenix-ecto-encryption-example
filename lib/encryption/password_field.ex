defmodule Encryption.PasswordField do
  # alias Encryption.AES
  alias Argon2.Base

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
    Base.hash_password(value, Argon2.gen_salt(), [{:argon2_type, 2}])
  end

  def verify_pass(password, stored_hash) do
    Argon2.verify_pass(password, stored_hash)
  end
end
