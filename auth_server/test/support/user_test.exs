defmodule AuthServer.UserTest do
  use ExUnit.Case

  import Ecto
  import Ecto.Query

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(AuthServer.Repo)
  end

  test "create user" do
  end

  test "auth user" do
  end

  test "delete user" do
  end
end
