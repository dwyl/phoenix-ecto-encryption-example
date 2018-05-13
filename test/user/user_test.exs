defmodule Encryption.UserTest do
  use Encryption.DataCase
  alias Encryption.User

  @valid_attrs %{
    name: "Max",
    email: "max@example.com", # Encryption.AES.encrypt(
    key_id: 1,
    password: "NoCarbsBeforeMarbs" # Encryption.HashField.hash("NoCarbsBeforeMarbs")
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

  test "can decrypt values of encrypted fields when loaded from database" do
    Repo.insert! User.changeset(%User{}, @valid_attrs)
    user = User.one()
    assert user.name  == @valid_attrs.name
    assert user.email == @valid_attrs.email
  end

  test "inserting a user sets the :email_hash field" do
    user = Repo.insert! User.changeset(%User{}, @valid_attrs)
    assert user.email_hash == Encryption.HashField.hash(@valid_attrs.email)
  end

  test "changeset validates uniqueness of email through email_hash" do
    Repo.insert! User.changeset(%User{}, @valid_attrs) # first insert works.
    # Now attempt to insert the *same* user again:
    {:error, changeset} = Repo.insert User.changeset(%User{}, @valid_attrs)
    {:ok, message} = Keyword.fetch(changeset.errors, :email_hash)
    msg = List.first(Tuple.to_list(message))
    assert "has already been taken" == msg
  end

  test "cannot query on email field due to encryption not producing same value twice" do
    Repo.insert! User.changeset(%User{}, @valid_attrs)
    assert Repo.get_by(User, email: @valid_attrs.email) == nil
  end

  test "User.get_by_email finds the user by their email address" do
    Repo.insert! User.changeset(%User{}, @valid_attrs)
    {:ok, user} = User.get_by_email(@valid_attrs.email)
    assert user.name == @valid_attrs.name
  end

  test "User.get_by_email user NOT found" do
    Repo.insert! User.changeset(%User{}, @valid_attrs)
    {:error, error_msg} = User.get_by_email("unregistered@mail.net")
    assert error_msg ==  "user not found"
  end

  test "can query on email_hash field because sha256 is deterministic" do
    Repo.insert! User.changeset(%User{}, @valid_attrs)

    assert %User{} = Repo.get_by(User,
      email_hash: Encryption.HashField.hash(@valid_attrs.email))
    assert %User{} = Repo.one(from u in User,
      where: u.email_hash == ^Encryption.HashField.hash(@valid_attrs.email))
  end
end
