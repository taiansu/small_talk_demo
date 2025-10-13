defmodule SmallTalkWeb.ChatLive do
  use SmallTalkWeb, :live_view

  alias SmallTalk.Chat

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Chat.subscribe()

    socket =
      socket
      |> assign(
        current_user: nil,
        emoji_options:
          Enum.take_random(
            [
              "🐵",
              "🐶",
              "🦊",
              "🐱",
              "🦁",
              "🐯",
              "🐴",
              "🦄",
              "🐮",
              "🐷",
              "🐽",
              "🐏",
              "🐭",
              "🐹",
              "🐰",
              "🐻",
              "🐻‍❄️",
              "🐨",
              "🐼",
              "🐤",
              "🐸",
              "🐢",
              "🦕",
              "🦖",
              "🐳",
              "🐬",
              "🐠",
              "🐡",
              "🦈",
              "🐙",
              "🐚",
              "🦀",
              "🦑",
              "🐌",
              "🦋",
              "🐝",
              "🦠"
            ],
            4
          ),
        color_options:
          Enum.take_random(["red", "green", "blue", "yellow", "purple", "orange", "pink"], 4)
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-screen flex items-center flex-col max-w-lg mx-auto">
      <div class="p-4 border-b">
        <h1 class="text-2xl font-bold">Small Talk</h1>
      </div>

      <%= if @current_user do %>
        <.chat_room messages={@streams.messages} current_user={@current_user} />
      <% else %>
        <.setup_form emoji_options={@emoji_options} color_options={@color_options} />
      <% end %>
    </div>
    """
  end

  defp chat_room(assigns) do
    ~H"""
    <div id="messages" class="flex-1 p-4 overflow-y-auto" phx-update="stream">
      <div :for={{dom_id, message} <- @messages} id={dom_id}>
        <.message dom_id={dom_id} message={message} />
      </div>
    </div>
    <div class="p-4 border-t">
      <form phx-submit="send_message" class="flex items-center">
        <span class="text-3xl">{@current_user.emoji}</span>
        <input
          id="message-body"
          type="text"
          name="body"
          class="input input-bordered flex-1 ml-2 mr-2"
          placeholder="我想說的話…"
          autocomplete="off"
          phx-autofocus
          phx-hook="ClearInput"
        />
        <button type="submit" class="btn btn-primary">Send</button>
      </form>
    </div>
    """
  end

  defp message(assigns) do
    ~H"""
    <div id={@dom_id} class="flex items-start mb-4">
      <span class="text-3xl mr-4">{@message.emoji}</span>
      <div class={["p-2", "rounded-lg", "bg-#{@message.color}-100"]}>
        <p class="font-bold">{@message.nickname}</p>
        <p class="text-gray-700">{@message.body}</p>
        <p class="text-xs text-gray-500">{@message.inserted_at}</p>
      </div>
    </div>
    """
  end

  defp setup_form(assigns) do
    ~H"""
    <div class="hidden">
      <div class="bg-red-100"></div>
      <div class="bg-green-100"></div>
      <div class="bg-blue-100"></div>
      <div class="bg-yellow-100"></div>
      <div class="bg-purple-100"></div>
      <div class="bg-orange-100"></div>
      <div class="bg-pink-100"></div>
      <div class="bg-gray-100"></div>
      <div class="bg-red-500"></div>
      <div class="bg-green-500"></div>
      <div class="bg-blue-500"></div>
      <div class="bg-yellow-500"></div>
      <div class="bg-purple-500"></div>
      <div class="bg-orange-500"></div>
      <div class="bg-pink-500"></div>
      <div class="bg-gray-500"></div>
    </div>
    <div class="flex-1 p-4 flex items-center justify-center">
      <form phx-submit="join" class="w-full max-w-sm p-8 bg-base-200 rounded-lg shadow-lg">
        <h2 class="text-2xl font-bold mb-6 text-center">Join Chat</h2>

        <div class="form-control mb-4">
          <label class="label" for="nickname">Nickname</label>
          <input
            type="text"
            name="nickname"
            id="nickname"
            class="input input-bordered w-full"
            required
            phx-autofocus
          />
        </div>

        <div class="form-control mb-4">
          <label class="label">Avatar Emoji</label>
          <div class="grid grid-cols-4 gap-2">
            <%= for emoji <- @emoji_options do %>
              <label class="cursor-pointer">
                <input
                  type="radio"
                  name="emoji"
                  value={emoji}
                  class="radio"
                  checked={emoji == hd(@emoji_options)}
                />
                <span class="text-3xl">{emoji}</span>
              </label>
            <% end %>
          </div>
        </div>

        <div class="form-control mb-6">
          <label class="label">Color</label>
          <% # The following classes are dynamically used and must be listed here for Tailwind's JIT compiler to see them. %>
          <% # accent-red, accent-green, accent-blue, accent-yellow, accent-purple, accent-orange, accent-pink, accent-gray %>
          <% # bg-red-500, bg-green-500, bg-blue-500, bg-yellow-500, bg-purple-500, bg-orange-500, bg-pink-500, bg-gray-500 %>
          <div class="grid grid-cols-4 gap-2">
            <%= for color <- @color_options do %>
              <label class="cursor-pointer flex flex-col items-center">
                <input
                  type="radio"
                  name="color"
                  value={color}
                  class="radio"
                  style={"accent-color: #{color}"}
                  checked={color == hd(@color_options)}
                />
                <div class={["w-8", "h-8", "rounded-full", "bg-#{color}-500", "mt-1"]}></div>
              </label>
            <% end %>
          </div>
        </div>

        <button type="submit" class="btn btn-primary w-full">Join</button>
      </form>
    </div>
    """
  end

  @impl true
  def handle_event("join", %{"nickname" => nickname, "emoji" => emoji, "color" => color}, socket) do
    socket =
      socket
      |> assign(:current_user, %{nickname: nickname, emoji: emoji, color: color})
      |> stream(:messages, Chat.list_messages())

    {:noreply, socket}
  end

  @impl true
  def handle_event("send_message", %{"body" => body}, socket) do
    with %{current_user: user} <- socket.assigns,
         {:ok, _} <- Chat.create_message(Map.merge(user, %{body: body})) do
      {:noreply, push_event(socket, "clear-input", %{})}
    else
      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    {:noreply, stream_insert(socket, :messages, message)}
  end
end
