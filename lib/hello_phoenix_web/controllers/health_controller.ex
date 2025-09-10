defmodule HelloPhoenixWeb.HealthController do
  use HelloPhoenixWeb, :controller

  def check(conn, _params) do
    # Cek koneksi database
    case Ecto.Adapters.SQL.query(HelloPhoenix.Repo, "SELECT 1", []) do
      {:ok, _} ->
        json(conn, %{status: "ok", database: "connected"})
      {:error, _} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{status: "error", database: "disconnected"})
    end
  end
end
