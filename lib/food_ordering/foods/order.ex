defmodule FoodOrdering.Foods.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :order_number, :integer
    field :total_price, :decimal
    field :status, :string, default: "pending"
    field :delivery, :boolean
    field :address, :string
    field :phone, :string
    field :ime, :string
    field :priimek, :string

    has_many :order_items, FoodOrdering.Foods.OrderItem

    timestamps()
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [:order_number, :total_price, :status, :delivery, :address, :phone, :ime, :priimek])
    |> validate_required([:order_number, :total_price, :status, :delivery])
  end
end
