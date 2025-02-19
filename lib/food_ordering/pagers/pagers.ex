defmodule FoodOrdering.Pagers.Pagers do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reserved_order_numbers" do
    field :order_number, :integer
    field :expires_at, :utc_datetime_usec

    timestamps()
  end

  def changeset(order_number, attrs) do
    order_number
    |> cast(attrs, [:order_number, :expires_at])
    |> validate_required([:order_number, :expires_at])
    |> unique_constraint(:order_number)
  end
end
