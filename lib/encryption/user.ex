defmodule Encryption.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Encryption.{User, Repo, HashField, EncryptedField, PasswordField}

  schema "users" do
    field :email_hash, HashField # :binary
    field :email, EncryptedField # :binary
    field :key_id, :integer
    field :name, EncryptedField # :binary
    field :password, :binary, virtual: true # virtual means "don't persist"
    field :password_hash, PasswordField # :binary

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
    |> prepare_fields # hash and/or encrypt the personal data before db insert!
    |> unique_constraint(:email_hash) # only after the email has been hashed!
  end

  # prepare_fields/1 takes changeset and applies the reuired "dump" function.
  defp prepare_fields(changeset) do
    case changeset.valid? do # don't bother transforming the data if invalid.
      true ->
        struct = changeset.data.__struct__  # get name of Ecto Struct. e.g: User
        fields = struct.__schema__(:fields) # get list of fields in the Struct
        # create map of data transforms stackoverflow.com/a/29924465/1148249
        changes = Enum.reduce fields, %{}, fn field, acc ->
          type = struct.__schema__(:type, field)
          # only check the changeset if it's "valid" and
          if String.contains? Atom.to_string(type), "Encryption." do
            primary = case type do
              Encryption.HashField -> # "priary" field for :email_hash is :email
                :email
              Encryption.PasswordField ->
                :password
              _ ->
               field
            end
            data = Map.get(changeset.data, primary)    # get plaintext data
            {:ok, transformed_value} = type.dump(data) # dump (encrypt/hash)
            Map.put(acc, field, transformed_value)     # assign key:value to Map
          else
            acc  # always return the accumulator to avoid "nil is not a map!"
          end
        end
        %{changeset | changes: changes} # apply the changes to the changeset
      _ ->
      changeset # return the changeset unmodified for the next function in pipe
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

  @doc """
  Retrieve one user from the database by email address
  """
  def get_by_email(email) do
    result = Repo.get_by(User, email_hash: HashField.hash(email))
    case result do
      nil -> # checking for nil case: github.com/elixir-ecto/ecto/issues/1225
        {:error, "user not found"}
      _ ->
      user = %User{
        name: name, email: email, key_id: key_id, password_hash: password_hash
      } = result
      {:ok, email } = EncryptedField.load(email, key_id)
      {:ok, name} = EncryptedField.load(name, key_id)
      {:ok, %{user | email: email, name: name, password_hash: password_hash}}
    end
  end
end

defmodule Util do
  types = ~w[function nil integer binary bitstring list map float atom tuple pid port reference]
  for type <- types do
    def typeof(x) when unquote(:"is_#{type}")(x), do: unquote(type)
  end
end
