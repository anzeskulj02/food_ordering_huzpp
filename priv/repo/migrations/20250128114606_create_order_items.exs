defmodule FoodOrdering.Repo.Migrations.CreateOrderItems do
  use Ecto.Migration

  def change do
    create table(:order_items) do
      add :customizations, :map
      add :order_id, references(:orders, on_delete: :nothing)
      add :food_id, references(:foods, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:order_items, [:order_id])
    create index(:order_items, [:food_id])
  end
end
