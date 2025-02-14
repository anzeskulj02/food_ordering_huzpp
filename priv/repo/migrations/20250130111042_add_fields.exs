defmodule FoodOrdering.Repo.Migrations.AddFields do
  use Ecto.Migration

  def change do
    alter table("foods") do
      add :audio, :string
    end
  end
end
