defmodule FoodOrdering.Repo.Migrations.AddFieldsToOrder do
  use Ecto.Migration

  def change do
    alter table("orders") do
      add :delivery, :boolean
      add :address, :string
      add :phone, :string
      add :ime, :string
      add :priimek, :string
    end
  end
end
