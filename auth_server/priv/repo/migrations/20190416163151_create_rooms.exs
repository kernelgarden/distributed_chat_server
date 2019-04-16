defmodule AuthServer.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :user_id, references(:users)
    end
  end
end
