defmodule FoodOrdering.Foods.OrderItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "order_items" do
    belongs_to :order, FoodOrdering.Foods.Order
    belongs_to :food, FoodOrdering.Foods.Food
    field :customizations, :map

    timestamps()
  end

  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, [:order_id, :food_id, :customizations])
    |> validate_required([:order_id, :food_id, :customizations])
  end
end
