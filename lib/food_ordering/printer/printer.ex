defmodule FoodOrdering.Printer.Printer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "printer_status" do
    field :remaining_paper, :float, default: 80.0

    timestamps()
  end

  def changeset(printer_status, attrs) do
    printer_status
    |> cast(attrs, [:remaining_paper])
    |> validate_number(:remaining_paper, greater_than_or_equal_to: 0)
  end
end
