defmodule Encryption.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Encryption.{User, Repo}
  # alias Encryption.HashField, as: Hash # not using!
  alias Encryption.EncryptedField, as: Encrypt

  schema "users" do
    field :email, Encryption.EncryptedField
    field :email_hash, Encryption.HashField
    field :name, Encryption.EncryptedField

    timestamps()
  end

  # @required_fields ~w(name email)
  # @optional_fields ~w()

  @doc """
  Creates a changeset based on the user and attrs
  """
  def changeset(%User{} = user, attrs \\ %{}) do
    user
    |> Map.merge(attrs)
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> set_hashed_fields
    |> encrypt_fields

  end

  defp encrypt_fields(changeset) do
    case changeset.valid? do
      true ->
        {:ok, encrypted_email} = Encrypt.dump(changeset.data.email)
        {:ok, encrypted_name} = Encrypt.dump(changeset.data.name)
        changeset
        |> put_change(:email, encrypted_email)
        |> put_change(:name, encrypted_name)
      _ ->
        changeset
    end
  end

  defp set_hashed_fields(changeset) do
    case changeset.valid? do
      true ->
        changeset
        |> put_change(:email_hash, changeset.data.email)

      _ ->
        changeset
    end
  end

  def one() do
    user = %User{ name: name, email: email } = Repo.one(User)
    {:ok, email } = Encrypt.load(email)
    {:ok, name} = Encrypt.load(name)
    %{user | email: email, name: name}
  end

end
