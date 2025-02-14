defmodule FoodOrdering.Drinks.Drinks do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drinks" do
    field :name, :string
    field :price, :decimal
    field :slug, :string

    timestamps()
  end

  def changeset(food, attrs) do
    food
    |> cast(attrs, [:name, :price, :slug])
    |> validate_required([:name, :price, :slug])
  end
end
