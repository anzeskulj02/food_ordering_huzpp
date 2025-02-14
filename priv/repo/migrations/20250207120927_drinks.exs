defmodule FoodOrdering.Repo.Migrations.Drinks do
  use Ecto.Migration

  def change do
    create table(:drinks) do
      add :name, :string
      add :price, :decimal
      add :slug, :string

      timestamps(type: :utc_datetime)
    end
  end
end
