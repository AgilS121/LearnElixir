defmodule HelloPhoenixWeb.VersionController do
  use HelloPhoenixWeb, :controller

  def index(conn, _params) do
    json(conn, %{
      build_id: System.get_env("BUILD_ID") || "local",
      version: "1.0.0",
      timestamp: DateTime.utc_now()
    })
  end
end
