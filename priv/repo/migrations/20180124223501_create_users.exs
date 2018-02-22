defmodule Encryption.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :binary
      add :email_hash, :binary
      add :name, :binary
      add :password_hash, :binary
      add :key_id, :integer

      timestamps()
    end

  end
end
