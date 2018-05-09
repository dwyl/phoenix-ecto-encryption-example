defmodule Encryption.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Encryption.{User, Repo, HashField, EncryptedField, PasswordField}
  # alias Encryption.HashField
  # alias Encryption.EncryptedField


  schema "users" do
    field :email, EncryptedField # :binary
    field :email_hash, Encryption.HashField # :binary
    field :key_id, :integer
    field :name, EncryptedField # :binary
    field :password_hash, Encryption.PasswordField # :binary

    timestamps()
  end

  @doc """
  Creates a changeset based on the user and attrs
  """
  def changeset(%User{} = user, attrs \\ %{}) do
    # IO.inspect attrs, label: "attrs"
    # IO.inspect user, label: "user"
    user
    |> Map.merge(attrs)
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> set_hashed_fields
    |> unique_constraint(:email_hash)
    |> encrypt_fields
  end

  # defp prepare_fields(changeset, schema) do
  #
  # end


      # User.__schema__(:fields)
      # # |> IO.inspect
      # |> Enum.each(fn field ->
      #   IO.inspect field, label: field
      #   User.__schema__(:type, field)
      #   |> IO.inspect
      # end)
      # #
      # # IO.inspect changeset, lable: "changeset"


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

  defp set_hashed_fields(changeset) do
    case changeset.valid? do
      true ->
        changeset
        |> put_change(:email_hash, HashField.hash(changeset.data.email))
        |> put_change(:password_hash, PasswordField.hash(changeset.data.password))
      _ ->
        changeset # return unmodified
    end
  end

  def one() do
    user = %User{
      name: name, email: email, key_id: key_id, password_hash: password_hash } =
        Repo.one(User)
    {:ok, email } = EncryptedField.load(email, key_id)
    {:ok, name} = EncryptedField.load(name, key_id)
    %{user | email: email, name: name, password_hash: password_hash}
  end
end
