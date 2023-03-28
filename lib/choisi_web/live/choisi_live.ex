defmodule ChoisiWeb.ChoisiLive do
  alias ChoisiWeb.Presence
  use ChoisiWeb, :live_view

  defp default_coords do
    %{x: 50, y: 50}
  end

  @choisiview "choisiview"
  def mount(_params, _session, socket) do
    user = ChoisiWeb.User.create()
    coords = default_coords()
    socket_id = socket.id

    {:ok, _} =
      Presence.track(
        self(),
        @choisiview,
        socket_id,
        %{
          socket_id: socket_id,
          coords: coords,
          user: user
        }
      )

    ChoisiWeb.Endpoint.subscribe(@choisiview)

    initial_users =
      Presence.list(@choisiview)
      |> Enum.map(fn {_, data} -> data[:metas] |> List.first() end)

    {:ok,
     socket
     |> assign(:socket_id, socket_id)
     |> assign(:user, user)
     |> assign(:users, initial_users)}
  end

  def handle_event("mousedown", _event, socket) do
    current_time = DateTime.utc_now()

    updated =
      socket
      |> assign(:clicked, {true, current_time})

    {:noreply, updated}
  end

  def handle_event("cursor-move", %{"x" => x, "y" => y}, socket) do
    key = socket.id
    payload = %{coords: %{x: x, y: y}}

    metas =
      Presence.get_by_key(@choisiview, key)[:metas]
      |> List.first()
      |> Map.merge(payload)

    Presence.update(self(), @choisiview, key, metas)

    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff", payload: payload}, socket) do
    users =
      Presence.list(@choisiview)
      |> Enum.map(fn {_, data} -> data[:metas] |> List.first() end)

    IO.inspect(payload)

    {:noreply, socket |> assign(:users, users) |> assign(:socket_id, socket.id)}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <section id="main-content" phx-hook="TrackClientCursor">
      <h1>Name: <%= @user.name %></h1>
      <%= for user <- @users do %>
        <div style={"position: absolute; color: #{user.user.color}; left: #{user.coords.x}%; top: #{user.coords.y}%; "}>
          <%= user.user.name %>
        </div>
      <% end %>
    </section>
    """
  end
end
