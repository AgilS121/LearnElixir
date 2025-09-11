defmodule HelloPhoenix.Release do
  @app :hello_phoenix

  def migrate do
    {:ok, _} = Application.ensure_all_started(@app)
    for repo <- repos() do
      path = Application.app_dir(@app, "priv/repo/migrations")
      Ecto.Migrator.with_repo(repo, fn repo ->
        Ecto.Migrator.run(repo, path, :up, all: true)
      end)
    end
  end

  defp repos, do: Application.fetch_env!(@app, :ecto_repos)
end
