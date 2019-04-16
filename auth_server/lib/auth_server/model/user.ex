defmodule AuthServer.Model.User do
  use Ecto.Schema

  alias __MODULE__
  alias AuthServer.Repo

  import Ecto.Changeset

  schema "users" do
    field(:name, :string)
    field(:user_id, :string)
    field(:hashed_password, :string)
    field(:password, :string, virtual: true)
    has_many(:rooms, AuthServer.Model.Room)
    timestamps()
  end

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:user_id, :password, :name])
    |> validate_required([:user_id, :password, :name])
    |> unique_constraint(:user_id)
    |> put_hashed_password()
  end

  def get(user_id) do
    Repo.get_by(User, user_id: user_id)
  end

  def authenticate(nil, _password) do
    false
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
