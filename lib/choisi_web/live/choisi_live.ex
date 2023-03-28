defmodule ChoisiWeb.ChoisiLive do
  alias ChoisiWeb.Presence
  use ChoisiWeb, :live_view

  defp default_coords do
    %{x: 50, y: 50}
  end

  # defp live_view_topic(chat_id), do: "chat:#{chat_id}"

  @choisiview "choisiview"
  def mount(_params, _session, socket) do
    user = ChoisiWeb.User.create()
    coords = default_coords()
    socket_id = socket.id

    topic = @choisiview

    Presence.track(
      self(),
      topic,
      socket_id,
      %{
        socket_id: socket_id,
        coords: coords,
        user: user
      }
    )

    ChoisiWeb.Endpoint.subscribe(topic)

    IO.inspect(Presence.list(topic))

    initial_users =
      Presence.list(topic)
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

  def handle_params(%{"id" => id}, _uri, socket) do
    IO.puts("handle_params: #{id}")
    {:noreply, socket |> assign(:chat_id, id)}
  end

  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    users =
      Presence.list(@choisiview)
      |> Enum.map(fn {_, data} -> data[:metas] |> List.first() end)

    {:noreply, socket |> assign(:users, users) |> assign(:socket_id, socket.id)}
  end
end
