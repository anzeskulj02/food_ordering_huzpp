defmodule FoodOrdering.Menu do
  @moduledoc """
  The Menu context.
  """

  import Ecto.Query, warn: false
  alias FoodOrdering.Repo

  alias FoodOrdering.Foods.Food
  alias FoodOrdering.Foods.Order
  alias FoodOrdering.Foods.OrderItem
  alias FoodOrdering.Drinks.Drinks

  @doc """
  Returns the list of foods.

  ## Examples

      iex> list_foods()
      [%Food{}, ...]

  """

  def list_drinks  do
    Repo.all(Drinks)
  end

  def list_foods do
    Repo.all(Food)
    |> Repo.preload([:ingredients])
  end

  @doc """
  Gets a single food.

  Raises `Ecto.NoResultsError` if the Food does not exist.

  ## Examples

      iex> get_food!(123)
      %Food{}

      iex> get_food!(456)
      ** (Ecto.NoResultsError)

  """
  def get_food!(id), do: Repo.get!(Food, id)

  @doc """
  Creates a food.

  ## Examples

      iex> create_food(%{field: value})
      {:ok, %Food{}}

      iex> create_food(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_food(attrs \\ %{}) do
    %Food{}
    |> Food.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a food.

  ## Examples

      iex> update_food(food, %{field: new_value})
      {:ok, %Food{}}

      iex> update_food(food, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_food(%Food{} = food, attrs) do
    food
    |> Food.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a food.

  ## Examples

      iex> delete_food(food)
      {:ok, %Food{}}

      iex> delete_food(food)
      {:error, %Ecto.Changeset{}}

  """
  def delete_food(%Food{} = food) do
    Repo.delete(food)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking food changes.

  ## Examples

      iex> change_food(food)
      %Ecto.Changeset{data: %Food{}}

  """
  def change_food(%Food{} = food, attrs \\ %{}) do
    Food.changeset(food, attrs)
  end

  @doc """
  Fetches all orders that have state pending.

  ## Examples

      iex> list_pending_orders()
      [%Order{}, ...]

  """
  def list_pending_orders do
    Repo.all(from o in Order, where: o.status == "pending")
    |> Repo.preload(order_items: [:food])
  end

  @doc """
  Creates an order and associated order items from the given map.

  ## Examples

      iex> create_order(%{food: %{7 => %{id: 7, name: "Jufka", quantity: 1, ingredients: ["Cheese"]}}, total_price: 5.0})
      {:ok, %Order{}}

  """
  def create_order(order_data, order_number) do
    order_changeset = Order.changeset(%Order{}, %{total_price: order_data.total_price, order_number: order_number})
    case Repo.insert(order_changeset) do
      {:ok, order} ->
        order_data.food
        |> Enum.each(fn {_food_id, food_item} ->
          order_item_changeset =
            OrderItem.changeset(%OrderItem{}, %{
              order_id: order.id,
              food_id: food_item.id,
              customizations: %{
                "ingredients" => food_item.ingredients,
                "quantity" => food_item.quantity
              }
            })
          Repo.insert(order_item_changeset)
        end)
        {:ok, order}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
