defmodule Encryption.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Encryption.{User, Repo}
  alias Encryption.HashField, as: Hash # not using!
  alias Encryption.EncryptedField, as: Encrypt


  schema "users" do
    field :email, Encryption.EncryptedField # :binary
    field :email_hash, :binary
    field :key_id, :integer
    field :name, Encryption.EncryptedField # :binary
    field :password_hash, :binary

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
    |> encrypt_fields

  end

  defp prepare_fields(changeset, schema) do

  end



  defp encrypt_fields(changeset) do

    # User.__schema__(:fields)
    # # |> IO.inspect
    # |> Enum.each(fn field ->
    #   IO.inspect field, label: field
    #   User.__schema__(:type, field)
    #   |> IO.inspect
    # end)
    #
    # IO.inspect changeset, lable: "changeset"

    case changeset.valid? do
      true ->
        {:ok, encrypted_email} = Encrypt.dump(changeset.data.email)
        {:ok, encrypted_name} = Encrypt.dump(changeset.data.name)
        changeset
        # |> IO.inspect
        |> put_change(:email, encrypted_email)
        |> put_change(:name, encrypted_name)
      _ ->
        changeset
    end
  end

  defp set_hashed_fields(changeset) do
    case changeset.valid? do
      true ->
        put_change(changeset, :email_hash, Hash.hash(changeset.data.email))
      _ ->
        changeset # return unmodified
    end
  end

  def one() do
    user = %User{ name: name, email: email, key_id: key_id} = Repo.one(User)
    {:ok, email } = Encrypt.load(email, key_id)
    {:ok, name} = Encrypt.load(name, key_id)
    %{user | email: email, name: name}
  end
end
