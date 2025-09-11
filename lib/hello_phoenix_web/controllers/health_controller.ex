defmodule HelloPhoenixWeb.HealthController do
  use HelloPhoenixWeb, :controller
  def index(conn, _params), do: Plug.Conn.send_resp(conn, 200, "ok")
end
