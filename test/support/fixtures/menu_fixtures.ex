defmodule FoodOrdering.MenuFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FoodOrdering.Menu` context.
  """

  @doc """
  Generate a food.
  """
  def food_fixture(attrs \\ %{}) do
    {:ok, food} =
      attrs
      |> Enum.into(%{

      })
      |> FoodOrdering.Menu.create_food()

    food
  end
end
