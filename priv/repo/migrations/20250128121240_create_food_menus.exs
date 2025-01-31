defmodule FoodOrdering.Repo.Migrations.CreateFoodMenus do
  use Ecto.Migration

  def change do
    create table(:food_menus) do

      timestamps(type: :utc_datetime)
    end
  end
end
