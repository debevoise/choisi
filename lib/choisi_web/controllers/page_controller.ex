defmodule ChoisiWeb.PageController do
  use ChoisiWeb, :controller

  def home(conn, _params) do
    session = conn |> get_session()
    # The home page is often custom made,
    # so skip the default app layout.

    case session do
      %{"user" => _user} ->
        conn

      _ ->
        conn |> put_session(:user, ChoisiWeb.User.create())
    end

    render(conn, :home, layout: false)
  end
end
