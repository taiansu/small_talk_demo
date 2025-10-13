defmodule SmallTalkWeb.PageController do
  use SmallTalkWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
