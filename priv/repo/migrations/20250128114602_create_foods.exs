defmodule FoodOrdering.Repo.Migrations.CreateFoods do
  use Ecto.Migration

  def change do
    create table(:foods) do
      add :name, :string
      add :price, :decimal
      add :description, :text

      timestamps(type: :utc_datetime)
    end
  end
end
