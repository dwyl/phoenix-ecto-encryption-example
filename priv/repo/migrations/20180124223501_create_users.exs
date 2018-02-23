defmodule Encryption.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :binary         # encrypted email address
      add :email_hash, :binary    # a sha256 hash of the email for fast lookup.
      add :name, :binary          # the person's name, encrypted.
      add :password_hash, :binary # one-way hash so nobody can "recover" it.
      add :key_id, :integer       # the id of the encryption key.

      timestamps()                # Ecto/Phoenix "inserted_at" field.
    end
    create unique_index(:users, [:email_hash]) # ensure email address is unique
  end
end
