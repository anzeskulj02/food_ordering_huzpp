defmodule FoodOrdering.Repo do
  use Ecto.Repo,
    otp_app: :food_ordering,
    adapter: Ecto.Adapters.Postgres
end
