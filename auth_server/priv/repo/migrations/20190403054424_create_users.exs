defmodule AuthServer.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :user_id, :string
      add :hashed_password, :string
      timestamps()
    end
  end
end
