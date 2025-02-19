defmodule FoodOrdering.Repo.Migrations.AddFields do
  use Ecto.Migration

  def change do
    alter table("foods") do
      add :slug, :string
      add :calories, :string
    end
  end
end
