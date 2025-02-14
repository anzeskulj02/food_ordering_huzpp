defmodule FoodOrdering.Repo.Migrations.AddFieldsAudio do
  use Ecto.Migration

  def change do
    alter table("foods") do
      add :audio, :string
    end
  end
end
