defmodule FoodOrdering.Repo.Migrations.CreateReservedOrderNumbers do
  use Ecto.Migration

  def change do
    create table(:reserved_order_numbers) do
      add :order_number, :integer, null: false
      add :expires_at, :utc_datetime_usec, null: false

      timestamps()
    end

    create unique_index(:reserved_order_numbers, [:order_number])
  end
end
