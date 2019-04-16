defmodule ChatServer.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :name, :string
      add :invite_code, :string
      add :owner_id, :integer
    end
  end
end
