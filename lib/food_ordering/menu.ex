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
  alias FoodOrdering.Pagers.Pagers
  alias FoodOrdering.Sales.FoodSale
  alias FoodOrdering.Printer.Printer

  @receipt_length 0.5

  def list_drinks  do
    Repo.all(Drinks)
  end

  def list_foods do
    Repo.all(Food)
    |> Repo.preload([:ingredients])
  end

  def list_sales do
    Repo.all(from s in FoodSale, order_by: [desc: s.quantity_sold])
  end

  def record_sale(order) do
    order.food
    |> Map.values()
    |> Enum.each(fn %{name: food_name, quantity: qty} ->
      sale = Repo.get_by(FoodSale, food_name: food_name)

      case sale do
        nil ->
          %FoodSale{}
          |> Ecto.Changeset.change(food_name: food_name, quantity_sold: qty)
          |> Repo.insert()

        %FoodSale{} = existing_sale ->
          existing_sale
          |> Ecto.Changeset.change(quantity_sold: existing_sale.quantity_sold + qty)
          |> Repo.update()
      end
    end)
  end

  def use_paper do
    case Repo.one(from p in Printer, limit: 1) do
      nil ->
        Repo.insert!(%Printer{remaining_paper: 80.0 - @receipt_length})

      %Printer{} = printer ->
        new_amount = max(printer.remaining_paper - @receipt_length, 0.0)

        printer
        |> Ecto.Changeset.change(remaining_paper: new_amount)
        |> Repo.update()
    end
  end

  def get_remaining_paper do
    case Repo.one(from p in Printer, limit: 1) do
      nil ->
        %Printer{remaining_paper: 80.0}
        |> Repo.insert!()
        |> Map.get(:remaining_paper)

      %Printer{} = printer ->
        printer.remaining_paper
    end
  end

  def reset_paper do
    case Repo.one(from p in Printer, limit: 1) do
      nil ->
        Repo.insert!(%Printer{remaining_paper: 80.0})

      %Printer{} = printer ->
        printer
        |> Ecto.Changeset.change(remaining_paper: 80.0)
        |> Repo.update()
    end
  end

  def get_reserved_pagers do
    current_time = DateTime.utc_now()

    Repo.all(from r in Pagers, where: r.expires_at > ^current_time)
      |> Enum.map(&{&1.order_number, &1.expires_at})
  end

  def cleanup_expired_order_numbers do
    current_time = DateTime.utc_now()

    Repo.delete_all(from r in Pagers, where: r.expires_at <= ^current_time)
  end

  def generate_unique_order_number do
    cleanup_expired_order_numbers()
    current_time = DateTime.utc_now()

    reserved_numbers =
      Repo.all(
        from r in Pagers,
        where: r.expires_at > ^current_time,
        select: r.order_number
      )

    available_numbers = Enum.to_list(1..16) -- reserved_numbers

    case available_numbers do
      [] ->
        {:error, :no_available_pagers}
      numbers ->
        order_number = Enum.random(numbers)
        expires_at = DateTime.add(current_time, 10 * 60, :second)

        %Pagers{}
        |> Pagers.changeset(%{order_number: order_number, expires_at: expires_at})
        |> Repo.insert()

        {:ok, order_number}
    end
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

  def get_order(order_id) do
    Repo.get(Order, order_id)
    |> Repo.preload(order_items: [:food])
  end

  @doc """
  Creates an order and associated order items from the given map.

  ## Examples

      iex> create_order(%{food: %{7 => %{id: 7, name: "Jufka", quantity: 1, ingredients: ["Cheese"]}}, total_price: 5.0})
      {:ok, %Order{}}

  """
  def create_order(order_data, order_number) do
    order_changeset = Order.changeset(%Order{}, %{total_price: order_data.total_price, order_number: order_number, delivery: false})
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

  def create_order_delivery(order_data, order_number, delivery_data) do
    order_changeset = Order.changeset(%Order{}, %{total_price: order_data.total_price, order_number: order_number, delivery: true, ime: delivery_data.ime, priimek: delivery_data.priimek, phone: delivery_data.phone, address: delivery_data.address})
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

  def delete_orders do
    Repo.delete_all(OrderItem)
    Repo.delete_all(Order)
  end

  def get_delivery_orders do
    Order
    |> where([o], o.delivery == true)
    |> Repo.all()
  end
end
