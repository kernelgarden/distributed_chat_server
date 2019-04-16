defmodule AuthServer.Model.Room do
  use Ecto.Schema

  alias __MODULE__
  alias AuthServer.Repo

  import Ecto.Changeset

  schema "rooms" do
    belongs_to(:user, AuthServer.Model.User)
  end
end
