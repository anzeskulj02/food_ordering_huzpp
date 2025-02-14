defmodule FoodOrderingWeb.DeliveryLive do
  use FoodOrderingWeb, :live_view
  alias FoodOrderingWeb.CustomComponents
  alias Phoenix.PubSub

  alias FoodOrdering.Menu

  alias FoodOrdering.Foods.Order
  alias FoodOrdering.Foods.OrderItem

  alias Escpos.Commands.{Text, TextFormat}
  alias Escpos.Printer

  @topic "food_orders"

  def mount(_params, _session, socket) do
    foods =
      Menu.list_foods()
        |> Enum.map(fn food -> %{id: food.id, name: food.name, description: food.description, price: Decimal.to_float(food.price), calories: Decimal.to_float(food.calories), ingredients: Enum.map(food.ingredients, & &1.name), slug: food.slug} end)
    {:ok,
     socket
     |> assign(:foods, foods)
     |> assign(:order, %{:food => %{}, :total_price => 0})
     |> assign(:selected_food, nil)
     |> assign(:order_view, false)
     |> assign(:quantity_counter, 1)
     |> assign(:welcome_block, true)
     |> assign(:loading, false)}
  end

  def render(assigns) do
    ~H"""
    <%= if @welcome_block==true do %>
      <CustomComponents.welcome_block />
    <% end %>

    <%= if @loading==true do %>
      <CustomComponents.loading_block />
    <% end %>

    <%= if @order_view do %>
      <CustomComponents.order_block order={@order} />
    <% end %>
      <div class="mb-28">
        <%= for food <- @foods do %>
          <div class="w-full my-10 bg-white border border-gray-200 rounded-lg shadow-sm">
            <%= if @selected_food && @selected_food.id == food.id do %>
              <CustomComponents.detailed_block food={@selected_food} quantity={@quantity_counter}/>
            <% else %>
              <CustomComponents.information_block food={food} />
            <% end %>
          </div>
        <% end %>
      </div>
      <footer class="fixed bottom-0 left-0 z-20 w-full bg-white border-t border-gray-200 shadow-sm flex items-center justify-between p-6">
        <span class="text-xl font-medium text-gray-900 sm:text-center"> Cena: <%= Map.get(@order, :total_price) %> €</span>
        <ul class="flex flex-wrap items-center mt-3 text-lg font-medium text-gray-500 sm:mt-0">
            <li>
                <a phx-click="finish_order" class="hover:underline">Preglej in zaključi naročilo</a>
            </li>
        </ul>
      </footer>
    """
  end

  # Hande event for adding food to the order (in detailed view of the food)
  def handle_event("add_to_order", %{"id_food" => food_id, "quantity-input" => quantity, "ingredients" => selected_ingredients}, socket) do
    food = Enum.find(socket.assigns.foods, fn food -> food.id == String.to_integer(food_id) end)
    quantity = String.to_integer(quantity)

    updated_food = Map.put(food, :quantity, quantity)
    updated_food = Map.put(updated_food, :ingredients, selected_ingredients)

    updated_order =
      socket.assigns.order
      |> Map.update(:food, %{}, fn foods ->
        Map.update(foods, food.id, updated_food, fn existing ->
          %{existing | quantity: existing.quantity + quantity, ingredients: selected_ingredients}
        end)
      end)
      |> Map.update(:total_price, 0, &(&1 + (food.price * quantity)))

    {:noreply, assign(socket, order: updated_order, selected_food: nil)}
  end

  def handle_event("quantity_change", %{"direction" => direction}, socket) do
    quantity =
      if direction == "increment" do
        socket.assigns.quantity_counter + 1
      else
        if socket.assigns.quantity_counter == 1 do
          1
        else
          socket.assigns.quantity_counter - 1
        end
      end
    {:noreply, assign(socket, quantity_counter: quantity)}
  end

  # Handle event for caneling food order in detailed view of the food
  def handle_event("cancle_order", _params, socket) do
    {:noreply, assign(socket, :selected_food, nil)}
  end

  #Handle event for finishing the order. Displaying review of the order
  def handle_event("finish_order", _params, socket) do
    socket= assign(socket, :order_view, true)
    {:noreply, socket}
  end

  def handle_event("close_order_view", _params, socket) do
    socket= assign(socket, :order_view, false)
    {:noreply, socket}
  end

  # Handle event for confirming the order. FINAL STEP
  def handle_event("confirm_order", _params, socket) do
    #generate number for the order (needs to be synced with the restaurant pager system. need to have a variable to store all active and incative pagers and then decide which one to use)
    order_number = :rand.uniform(10)

    order = transform_order(socket.assigns.order, order_number)

    PubSub.broadcast(FoodOrdering.PubSub, @topic, {:new_order, order})

    Menu.create_order(socket.assigns.order, order_number)

    socket= assign(socket, order_view: false, order: %{:food => %{}, :total_price => 0}, loading: true)

    {:noreply, socket}
  end

  def handle_event("remove_from_order", %{"id" => food_id}, socket) do
    food = Enum.find(socket.assigns.foods, fn food -> food.id == String.to_integer(food_id) end)
    quantity = Map.get(socket.assigns.order, :food)[food.id].quantity

    updated_order =
      socket.assigns.order
      |> Map.update(:food, %{}, fn foods ->
        Map.delete(foods, food.id)
      end)
      |> Map.update(:total_price, 0, &(&1 - (food.price * quantity)))

    {:noreply, assign(socket, order: updated_order)}
  end

  # Handle event for selecting more information about the food. From informational view to detailed view
  def handle_event("select_more", %{"id" => food_id}, socket) do
    selected_food = Enum.find(socket.assigns.foods, fn food -> food.id == String.to_integer(food_id) end)

    {:noreply, assign(socket, selected_food: selected_food)}
  end

  def handle_event("remove_welcome", _parans, socket) do
    {:noreply, assign(socket, welcome_block: false)}
  end

  def transform_order(order_map, order_number) do
    %{
      food: food_map,
      total_price: total_price
    } = order_map

    order_number = order_number
    status = "Pending"

    order_items =
      food_map
      |> Enum.map(fn {_id, food} ->
        %{
          food: %{
            name: food.name
          },
          customizations: %{
            "quantity" => food.quantity,
            "ingredients" => food.ingredients
          }
        }
      end)

    %{
      order_number: order_number,
      status: status,
      total_price: total_price,
      order_items: order_items
    }
  end
end
