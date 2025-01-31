defmodule FoodOrdering.Foods.Food do
  use Ecto.Schema
  import Ecto.Changeset

  schema "foods" do
    field :name, :string
    field :price, :decimal
    field :description, :string
    field :slug, :string
    field :calories, :decimal

    has_many :food_ingredients, FoodOrdering.Foods.FoodIngredient
    has_many :ingredients, through: [:food_ingredients, :ingredient]

    timestamps()
  end

  def changeset(food, attrs) do
    food
    |> cast(attrs, [:name, :price, :description, :calories, :slug])
    |> validate_required([:name, :price, :calories, :slug])
  end
end
