defmodule Encryption.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Encryption.User


  schema "users" do
    field :email, :binary
    field :email_hash, :binary
    field :name, :binary

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :email, :email_hash])
    |> validate_required([:name, :email, :email_hash])
  end
end
