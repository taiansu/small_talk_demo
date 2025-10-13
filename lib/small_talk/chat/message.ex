defmodule SmallTalk.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :body, :string
    field :color, :string
    field :emoji, :string
    field :nickname, :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:nickname, :emoji, :color, :body])
    |> validate_required([:nickname, :emoji, :color, :body])
  end
end
