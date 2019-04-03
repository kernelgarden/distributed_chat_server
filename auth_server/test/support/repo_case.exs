defmodule AuthServer.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote  do
      alias AuthServer.Repo

      import Ecto
      import Ecto.Query
      import AuthServer.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(AuthServer.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(AuthServer.Repo, {:shared, self()})
    end

    :ok
  end

end
