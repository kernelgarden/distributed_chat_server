defmodule AuthServer.UserTest do
  use ExUnit.Case

  import Ecto
  import Ecto.Query

  alias AuthServer.Repo
  alias AuthServer.Model.User

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(AuthServer.Repo)

    %User{}
      |> User.changeset(%{user_id: "test_id", password: "password", name: "testman"})
      |> Repo.insert()

    user = Repo.get_by(User, user_id: "test_id")

    {:ok, user: user}
  end

  test "create user", _context do
    new_user = %{user_id: "test_id2", password: "password", name: "testman"}

    result =
      %User{}
      |> User.changeset(new_user)
      |> Repo.insert()

    assert elem(result, 0) == :ok

    user = elem(result, 1)

    assert user.user_id == new_user.user_id
    assert user.password == new_user.password
    assert user.name == new_user.name

    stored_user = Repo.get_by(User, user_id: new_user.user_id)

    assert stored_user != nil
    assert stored_user.password == nil
  end

  test "duplicate check test", context do
    user = context.user
    dummy_user = %{user_id: user.user_id, password: user.password, name: user.name}

    result =
      %User{}
      |> User.changeset(dummy_user)
      |> Repo.insert()

    assert elem(result, 0) == :error
  end

  test "auth user", context do
    # 정상 요청 케이스
    request = %{user_id: "test_id", password: "password"}

    result =
      User.get(request.user_id)
      |> User.authenticate(request.password)

    assert result == true

    # 패스워드가 틀린 케이스
    fake_request = %{user_id: "test_id", password: "passwor"}

    result =
      User.get(fake_request.user_id)
      |> User.authenticate(fake_request.password)

    assert result == false

    # id가 틀린 케이스
    fake_request2 = %{user_id: "test_id11", password: "password"}

    result =
      User.get(fake_request2.user_id)
      |> User.authenticate(fake_request2.password)

    assert result == false

  end

end
