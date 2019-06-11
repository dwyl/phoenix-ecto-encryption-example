defmodule Encryption.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Encryption.{User, Repo, HashField, EncryptedField, PasswordField}

  # Map inputs to outputs for the HashFields and PasswordFields
  @field_source_map [email_hash: :email, password_hash: :password]

  schema "users" do
    # :binary
    field(:email_hash, HashField)
    # :binary
    field(:email, EncryptedField)
    field(:key_id, :integer)
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
    # hash and/or encrypt the personal data before db insert!
    # only after the email has been hashed!
    user
    |> Map.merge(attrs)
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> prepare_fields
    |> unique_constraint(:email_hash)
  end

  # prepare_fields/1 takes changeset and applies the required "dump" function.
  # only apply the "dump" function if the changeset is valid
  defp prepare_fields(%Ecto.Changeset{valid?: true} = changeset) do
    # 1) get each field and their respective type
    # 2) check if the type is a custom type (see is_custom_type?/1)
    # 3) if it is a custom type, check @field_source_map to see which field
    #    supplies the input data
    # 4) proceed to apply `dump/1` to transform the data into the final value

    changes =
      Enum.reduce(changeset.types, %{}, fn {field, type}, accumulator ->
        case is_custom_type?(type) do
          true ->
            data_source = Keyword.get(@field_source_map, field, field)
            data = Map.get(changeset.data, data_source)

            {:ok, transformed_value} = Kernel.apply(type, :dump, [data])
            Map.put(accumulator, field, transformed_value)

          false ->
            accumulator
        end
      end)

    # 5) apply the transformations to the changeset
    %{changeset | changes: changes}
  end

  # do not transform the data if it's invalid
  defp prepare_fields(changeset), do: changeset

  # Check whether the type is a custom type.
  defp is_custom_type?(type), do: function_exported?(type, :dump, 1)

  @doc """
  Retrieve one user from the database and decrypt the encrypted data.
  """
  def one() do
    user =
      %User{name: name, email: email, key_id: key_id, password_hash: password_hash} =
      Repo.one(User)

    {:ok, email} = EncryptedField.load(email, key_id)
    {:ok, name} = EncryptedField.load(name, key_id)
    %{user | email: email, name: name, password_hash: password_hash}
  end

  @doc """
  Retrieve one user from the database by email address
  """
  def get_by_email(email) do
    result = Repo.get_by(User, email_hash: HashField.hash(email))

    case result do
      # checking for nil case: github.com/elixir-ecto/ecto/issues/1225
      nil ->
        {:error, "user not found"}

      _ ->
        user =
          %User{
            name: name,
            email: email,
            key_id: key_id,
            password_hash: password_hash
          } = result

        {:ok, email} = EncryptedField.load(email, key_id)
        {:ok, name} = EncryptedField.load(name, key_id)
        {:ok, %{user | email: email, name: name, password_hash: password_hash}}
    end
  end
end
