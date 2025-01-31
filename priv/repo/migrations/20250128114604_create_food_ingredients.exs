defmodule FoodOrdering.Repo.Migrations.CreateFoodIngredients do
  use Ecto.Migration

  def change do
    create table(:food_ingredients) do
      add :food_id, references(:foods, on_delete: :nothing)
      add :ingredient_id, references(:ingredients, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:food_ingredients, [:food_id])
    create index(:food_ingredients, [:ingredient_id])
  end
end
