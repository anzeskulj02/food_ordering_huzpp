defmodule FoodOrdering.Sales.FoodSale do
  use Ecto.Schema
  import Ecto.Changeset

  schema "food_sales" do
    field :food_name, :string
    field :quantity_sold, :integer, default: 0

    timestamps()
  end

  def changeset(food_sale, attrs) do
    food_sale
    |> cast(attrs, [:food_name, :quantity_sold])
    |> validate_required([:food_name, :quantity_sold])
  end
end
