defmodule FoodOrdering.Foods.FoodIngredient do
  use Ecto.Schema
  import Ecto.Changeset

  schema "food_ingredients" do
    belongs_to :food, FoodOrdering.Foods.Food
    belongs_to :ingredient, FoodOrdering.Foods.Ingredient

    timestamps()
  end

  def changeset(food_ingredient, attrs) do
    food_ingredient
    |> cast(attrs, [:food_id, :ingredient_id])
    |> validate_required([:food_id, :ingredient_id])
  end
end
