defmodule Encryption.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Encryption.{User, Repo, HashField, EncryptedField, PasswordField}

  schema "users" do
    # :binary
    field(:email_hash, HashField)
    # :binary
    field(:email, EncryptedField)
    # :binary
    field(:name, EncryptedField)
    # virtual means "don't persist"
    field(:password, :binary, virtual: true)
    # :binary
    field(:password_hash, PasswordField)

    # creates columns for inserted_at and updated_at timestamps. =)
    timestamps()
  end

  @doc """
  Creates a changeset based on the user and attrs
  """
  def changeset(%User{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:email])
    |> add_email_hash
    |> unique_constraint(:email_hash)
  end

  @doc """
  Retrieve one user from the database by email address
  """
  def get_by_email(email) do
    Repo.get_by(User, email_hash: email)
  end

  defp add_email_hash(changeset) do
    if Map.has_key?(changeset.changes, :email) do
      changeset |> put_change(:email_hash, changeset.changes.email)
    else
      changeset
    end
  end
end
