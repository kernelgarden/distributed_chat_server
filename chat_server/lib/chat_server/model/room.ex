defmodule ChatServer.Model.Room do
  use Ecto.Schema

  alias __MODULE__
  alias ChatServer.Repo

  import Ecto.Changeset

  schema "rooms" do
    field(:name, :string)
    field(:user_id, :string)
    field(:hashed_password, :string)
    field(:password, :string, virtual: true)
    timestamps()
  end

  def get(user_id) do
    Repo.get_by(User, user_id: user_id)
  end
end
