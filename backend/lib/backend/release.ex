defmodule Backend.Release do
  @app :backend

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def seed do
    load_app()
    seeds_path = Path.join([:code.priv_dir(@app), "repo", "seeds.exs"])
    Ecto.Migrator.with_repo(Backend.Repo, fn _repo ->
      Code.eval_file(seeds_path)
    end)
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
