defmodule Encryption.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Encryption.{User, Repo, HashField, EncryptedField, PasswordField}

  schema "users" do
    field :email, EncryptedField # :binary
    field :email_hash, Encryption.HashField # :binary
    field :key_id, :integer
    field :name, EncryptedField # :binary
    field :password, :binary, virtual: true # virtual means "don't persist"
    field :password_hash, Encryption.PasswordField # :binary

    timestamps() # creates columns for inserted_at and updated_at timestamps. =)
  end

  @doc """
  Creates a changeset based on the user and attrs
  """
  def changeset(%User{} = user, attrs \\ %{}) do
    user
    |> Map.merge(attrs)
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> set_hashed_fields
    |> unique_constraint(:email_hash)
    |> encrypt_fields
  end

  # encrypt the two fields we want to be able to decrypt later: email & name.
  defp encrypt_fields(changeset) do
    case changeset.valid? do
      true ->
        {:ok, encrypted_email} = EncryptedField.dump(changeset.data.email)
        {:ok, encrypted_name} = EncryptedField.dump(changeset.data.name)
        changeset
        |> put_change(:email, encrypted_email)
        |> put_change(:name, encrypted_name)
      _ ->
        changeset
    end
  end

  # hash email address for fast+secure lookup and password for strong security.
  defp set_hashed_fields(changeset) do
    case changeset.valid? do
      true ->
        changeset
        |> put_change(:email_hash, HashField.hash(changeset.data.email))
        |> put_change(:password_hash,
          PasswordField.hash_password(changeset.data.password))
      _ ->
        changeset # return unmodified
    end
  end

  @doc """
  Retrieve one user from the database and decrypt the encrypted data.
  """
  def one() do
    user = %User{
      name: name, email: email, key_id: key_id, password_hash: password_hash } =
        Repo.one(User)
    {:ok, email } = EncryptedField.load(email, key_id)
    {:ok, name} = EncryptedField.load(name, key_id)
    %{user | email: email, name: name, password_hash: password_hash}
  end
end
