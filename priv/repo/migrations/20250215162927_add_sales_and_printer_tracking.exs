defmodule FoodOrdering.Repo.Migrations.AddSalesAndPrinterTracking do
  use Ecto.Migration

  def change do
    create table(:food_sales) do
      add :food_name, :string
      add :quantity_sold, :integer, default: 0

      timestamps()
    end

    create table(:printer_status) do
      add :remaining_paper, :float, default: 80.0  # Start with full paper roll (80 meters)

      timestamps()
    end
  end
end
