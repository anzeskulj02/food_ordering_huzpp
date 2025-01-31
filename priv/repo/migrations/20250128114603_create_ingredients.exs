defmodule FoodOrdering.Repo.Migrations.CreateIngredients do
  use Ecto.Migration

  def change do
    create table(:ingredients) do
      add :name, :string
      add :additional_price, :decimal

      timestamps(type: :utc_datetime)
    end
  end
end
