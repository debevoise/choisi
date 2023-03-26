defmodule ChoisiWeb.ChoisiLive do
  use ChoisiWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:user, ChoisiWeb.User.create())
     |> assign(:coords, %{x: 50, y: 50})
     |> assign(:clicked, false)}
  end

  def handle_event("cursor-move", %{"x" => x, "y" => y}, socket) do
    updated =
      socket
      |> assign(:coords, %{x: x, y: y})

    {:noreply, updated}
  end

  def handle_event("mousedown", _event, socket) do
    current_time = DateTime.utc_now()

    updated =
      socket
      |> assign(:clicked, {true, current_time})

    {:noreply, updated}
  end

  def handle_event("mouseup", _event, socket) do
    updated =
      socket
      |> assign(:clicked, false)

    {:noreply, updated}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <main id="main-content" phx-hook="TrackClientCursor">
      <h1>Name: <%= @user.name %></h1>
      <div style={"position: absolute; color: #{@user.color}; left: #{@coords.x}%; top: #{@coords.y}%; "}>
        <%= @coords.x %> <%= @coords.y %>
      </div>
    </main>
    """
  end
end
