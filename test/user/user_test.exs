defmodule Encryption.UserTest do
  use Encryption.DataCase
  alias Encryption.User

  @valid_attrs %{
    name: "Max",
    email: "max@example.com",
    password: "NoCarbsBeforeMarbs"
  }

  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  describe "Verify correct working of encryption and hashing" do
    setup do
      user = Repo.insert!(User.changeset(%User{}, @valid_attrs))
      {:ok, user: user, email: @valid_attrs.email}
    end

    # test "inserting a user sets the :email_hash field", %{user: user} do
    #   assert user.email_hash == user.email
    # end

    test ":email_hash field is the encrypted hash of the email", %{user: user} do
      user_from_db = User |> Repo.one()
      assert user_from_db.email_hash == Encryption.HashField.hash(user.email)
    end

    test "changeset validates uniqueness of email through email_hash" do
      # Now attempt to insert the *same* user again:
      {:error, changeset} = Repo.insert(User.changeset(%User{}, @valid_attrs))

      assert changeset.errors == [
               email_hash:
                 {"has already been taken",
                  [constraint: :unique, constraint_name: "users_email_hash_index"]}
             ]
    end

    test "can decrypt values of encrypted fields when loaded from database", %{user: user} do
      found_user = Repo.one(User)
      assert found_user.name == user.name
      assert found_user.email == user.email
    end

    test "User.get_by_email finds the user by their email address", %{user: user} do
      found_user = User.get_by_email(user.email)
      assert found_user.email == user.email
      assert found_user.email_hash == Encryption.HashField.hash(user.email)
    end

    test "User.get_by_email user NOT found" do
      assert User.get_by_email("unregistered@mail.net") == {:error, "user not found"}
    end

    test "cannot query on email field due to encryption not producing same value twice", %{
      user: user
    } do
      assert Repo.get_by(User, email: user.email) == nil
    end

    test "can query on email_hash field because sha256 is deterministic", %{user: user} do
      assert Repo.get_by(User, email_hash: user.email) == nil

      assert %User{} =
               Repo.one(
                 from(u in User,
                   where: u.email_hash == ^user.email
                 )
               )
    end

    test "Key rotation: add a new encryption key", %{email: email} do
      original_keys = Application.get_env(:encryption, Encryption.AES)[:keys]

      # add a new key
      Application.put_env(:encryption, Encryption.AES,
        keys: original_keys ++ [:crypto.strong_rand_bytes(32)]
      )

      # find user encrypted with previous key
      user = User.get_by_email(email)
      assert email == user.email

      Repo.insert!(User.changeset(%User{}, %{name: "Frank", email: "frank@example.com"}))

      user = User.get_by_email("frank@example.com")
      assert "frank@example.com" == user.email
      assert "Frank" == user.name

      # rollback to the original keys
      Application.put_env(:encryption, Encryption.AES, keys: original_keys)
    end
  end
end
