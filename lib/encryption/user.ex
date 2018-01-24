defmodule Encryption.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Encryption.User


  schema "users" do
    field :email, Encryption.EncryptedField
    field :email_hash, Encryption.HashField
    field :name, Encryption.EncryptedField

    timestamps()
  end

  # Ensure that hashed fields never get out of date
  # before_insert :set_hashed_fields
  # before_update :set_hashed_fields

  @required_fields ~w(name email)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the user and attrs
  """
  def changeset(%User{} = user, attrs \\ :empty) do
    IO.inspect user
    user
    |> cast(attrs, [:name, :email, :email_hash])
    |> validate_required([:name, :email, :email_hash])
    |> set_hashed_fields
    # |> validate_unique(:email_hash, on: Encryption.Repo)
    # |> unique_constraint(:email_hash)
    # |> validate_unique([:email_hash])
  end

  defp set_hashed_fields(changeset) do
    IO.inspect changeset
    changeset
    |> put_change(:email_hash, changeset.changes[:email] || changeset.model.email)
  end
end
