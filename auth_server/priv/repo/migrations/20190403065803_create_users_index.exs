defmodule AuthServer.Repo.Migrations.CreateUsersIndex do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:user_id])
  end
end
