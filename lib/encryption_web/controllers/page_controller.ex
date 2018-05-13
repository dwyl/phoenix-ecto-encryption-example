defmodule EncryptionWeb.PageController do
  use EncryptionWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
