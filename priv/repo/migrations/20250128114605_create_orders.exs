defmodule FoodOrdering.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :order_number, :integer
      add :total_price, :decimal
      add :status, :string

      timestamps(type: :utc_datetime)
    end
  end
end
