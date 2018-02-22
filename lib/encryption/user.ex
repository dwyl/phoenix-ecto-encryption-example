defmodule Encryption.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Encryption.User


  schema "users" do
    field :email, :binary
    field :email_hash, :binary
    field :key_id, :integer
    field :name, :binary
    field :password_hash, :binary

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    IO.inspect attrs

    user
    # |> put_change(:password_hash, Comeonin.Bcrypt.hashpwsalt(:pass))
    |> cast(attrs, [:email, :email_hash, :name, :password_hash, :key_id])
    |> validate_required([:email, :email_hash, :name, :password_hash, :key_id])
  end
end
