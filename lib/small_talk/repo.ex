defmodule SmallTalk.Repo do
  use Ecto.Repo,
    otp_app: :small_talk,
    adapter: Ecto.Adapters.Postgres
end
