defmodule FoodOrdering.Repo.Migrations.AddFields do
  use Ecto.Migration

  def change do
    alter table("ingredients") do
      add :slug, :string
    end

    alter table("foods") do
      add :slug, :string
      add :calories, :decimal
    end
  end
end
