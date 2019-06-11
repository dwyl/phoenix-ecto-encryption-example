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
    # get the list of fields that require transformations
    custom_types =
      changeset.types
      |> Map.keys()
      |> Enum.filter(&is_custom_type?(changeset, &1))

    # create the input-output mapping in the form of [output: input, ...]
    field_mapping =
      Enum.map(
        custom_types,
        fn field -> {field, Keyword.get(@field_source_map, field, field)} end
      )

    # apply transformations to the fields with a custom type
    changes =
      Enum.reduce(custom_types, %{}, fn field, accumulator ->
        data_source = Keyword.fetch!(field_mapping, field)
        data = Map.get(changeset.data, data_source)
        type = Map.get(changeset.types, field)

        {:ok, transformed_value} = Kernel.apply(type, :dump, [data])

        Map.put(accumulator, field, transformed_value)
      end)

    # apply the changes to the changeset
    %{changeset | changes: changes}
  end

  # do not transform the data if it's invalid
  defp prepare_fields(changeset), do: changeset

  # custom types export the dump/1 function, as per the Ecto.Type behaviour.
  defp is_custom_type?(changeset, field) do
    type = Map.get(changeset.types, field)
    function_exported?(type, :dump, 1)
  end

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
