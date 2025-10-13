defmodule SmallTalk.Chat do
  @moduledoc """
  The Chat context.
  """

  import Ecto.Query, warn: false
  alias SmallTalk.Repo

  alias SmallTalk.Chat.Message

  defp topic, do: "chat_room:messages"

  def subscribe do
    Phoenix.PubSub.subscribe(SmallTalk.PubSub, topic())
  end

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages do
    Repo.all(Message)
  end

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}} #         or
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> broadcast_message()
  end

  defp broadcast_message({:ok, message}) do
    Phoenix.PubSub.broadcast(SmallTalk.PubSub, topic(), {:new_message, message})
    {:ok, message}
  end

  defp broadcast_message({:error, reason}), do: {:error, reason}
end
