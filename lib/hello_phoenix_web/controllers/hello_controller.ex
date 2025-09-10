defmodule HelloPhoenixWeb.HelloController do
  use HelloPhoenixWeb, :controller

  def index(conn, _params) do
    text(conn, "Hello World, testing auto deploy")
  end
end
