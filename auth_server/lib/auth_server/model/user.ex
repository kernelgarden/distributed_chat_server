defmodule AuthServer.Model.User do
  use Ecto.Schema

  alias __MODULE__

  import Ecto.Changeset

  schema "people" do
    field(:name, :string)
    field(:user_id, :string)
    field(:hashed_password, :string)
    field(:password, :string, virtual: true)
    timestamps()
  end

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:player_name, :player_id, :password])
    |> validate_required([:player_name, :player_id, :password])
    |> unique_constraint(:player_id)
    |> put_hashed_password()
  end

  def authenticate(%User{hashed_password: hashed_password}, password) do
    Bcrypt.verify_pass(password, hashed_password)
  end

  defp put_hashed_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :hashed_password, Bcrypt.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end
end
