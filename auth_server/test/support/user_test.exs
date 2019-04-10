defmodule AuthServer.UserTest do
  use ExUnit.Case

  import Ecto
  import Ecto.Query

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(AuthServer.Repo)
  end

  test "create user2" do
  end

  test "auth user2" do
  end

  test "delete user2" do
  end

end
