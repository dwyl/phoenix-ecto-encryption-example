defmodule Consultify.Repo.Migrations.RemoveKeyIdFromUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove(:key_id)
    end
  end
end
