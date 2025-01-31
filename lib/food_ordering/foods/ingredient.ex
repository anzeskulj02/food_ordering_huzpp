defmodule FoodOrdering.Foods.Ingredient do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ingredients" do
    field :name, :string
    field :additional_price, :decimal
    field :slug, :string

    has_many :food_ingredients, FoodOrdering.Foods.FoodIngredient
    has_many :foods, through: [:food_ingredients, :food]

    timestamps()
  end

  def changeset(ingredient, attrs) do
    ingredient
    |> cast(attrs, [:name, :additional_price, :slug])
    |> validate_required([:name])
  end
end
