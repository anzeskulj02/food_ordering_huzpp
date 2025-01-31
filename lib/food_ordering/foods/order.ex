defmodule FoodOrdering.Foods.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :order_number, :integer
    field :total_price, :decimal
    field :status, :string, default: "pending"

    has_many :order_items, FoodOrdering.Foods.OrderItem

    timestamps()
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [:order_number, :total_price, :status])
    |> validate_required([:order_number, :total_price, :status])
  end
end
