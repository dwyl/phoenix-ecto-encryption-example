defmodule Encryption.UserTest do
  # use ExUnit.Case
  use Encryption.DataCase
  alias Encryption.User

  @valid_attrs %{
    name: "Max",
    email: "max@example.com", # Encryption.AES.encrypt(
    email_hash: Encryption.HashField.hash("max@example.com"),
    key_id: 1,
    password_hash: Encryption.HashField.hash("NoCarbsBeforeMarbs")
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

  # test "changeset validates uniqueness of email through email_hash" do
  #   Repo.insert! User.changeset(%User{}, @valid_attrs)
  #   assert {:email_hash, "has already been taken"}
  #     in errors_on(%User{}, %{email: @valid_attrs.email})
  # end

  test "can decrypt values of encrypted fields when loaded from database" do
    Repo.insert! User.changeset(%User{}, @valid_attrs)
    user = User.one()
    assert user.name  == @valid_attrs.name
    assert user.email == @valid_attrs.email

    assert user.email_hash == Encryption.HashField.hash(@valid_attrs.email)
  end

  test "inserting a user updates the :email_hash field" do
    user = Repo.insert! User.changeset(%User{}, @valid_attrs)
    assert user.email_hash == @valid_attrs.email
  end

  test "cannot query on email field due to encryption not producing same value twice" do
    Repo.insert! User.changeset(%User{}, @valid_attrs)
    assert Repo.get_by(User, email: @valid_attrs.email) == nil
  end

  test "can query on email_hash field because sha256 is deterministic" do
    Repo.insert! User.changeset(%User{}, @valid_attrs)

    assert %User{} = Repo.get_by(User, email_hash: @valid_attrs.email)
    assert %User{} = Repo.one(from u in User, where: u.email_hash == ^@valid_attrs.email)
  end
end
