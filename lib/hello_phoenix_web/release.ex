defmodule HelloPhoenix.Release do
  @app :hello_phoenix

  # Jalankan semua migrasi :up
  def migrate do
    {:ok, _} = Application.ensure_all_started(@app)
    repos()
    |> Enum.each(&run_migrations_for/1)
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp run_migrations_for(repo) do
    path = Application.app_dir(@app, "priv/repo/migrations")
    Ecto.Migrator.with_repo(repo, fn _repo ->
      Ecto.Migrator.run(repo, path, :up, all: true)
    end)
  end
end
