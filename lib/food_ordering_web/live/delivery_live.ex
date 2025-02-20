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
        |> Enum.map(fn food -> %{id: food.id, name: food.name, description: food.description, price: Decimal.to_float(food.price), calories: Decimal.to_float(food.calories), ingredients: Enum.map(food.ingredients, fn ingredient -> %{name: ingredient.name, slug: ingredient.slug} end), slug: food.slug} end)

    drinks =
        Menu.list_drinks()
        |> Enum.map(fn drink -> %{id: drink.id, name: drink.name, price: Decimal.to_float(drink.price), slug: drink.slug} end)

    {:ok,
      socket
      |> assign(:foods, foods)
      |> assign(:drinks, drinks)
      |> assign(:order, %{:food => %{}, :drinks => %{}, :total_price => 0})
      |> assign(:selected_food, nil)
      |> assign(:selected_drink, nil)
      |> assign(:order_view, false)
      |> assign(:quantity_counter, 1)
      |> assign(:welcome_block, true)
      |> assign(:loading, false)
      |> assign(:cebula_modal, false)
      |> assign(:pijaca, false)
      |> assign(:drink, nil)
      |> assign(:kontakt, %{})
      |> assign(:kontakt_view, false)}
   end

  def render(assigns) do
    ~H"""
    <%= if @welcome_block==true do %>
      <CustomComponents.welcome_block_delivery />
    <% end %>

    <%= if @loading==true do %>
      <CustomComponents.loading_block />
    <% end %>

    <%= if @cebula_modal==true do %>
      <CustomComponents.cebula_modal />
    <% end %>

    <%= if @pijaca==true do %>
      <CustomComponents.pijaca_modal_delivery drink={@selected_drink}/>
    <% end %>

    <%= if @kontakt_view==true do %>
      <CustomComponents.kontakt_block kontakt={@kontakt}/>
    <% end %>

    <%= if @order_view do %>
      <CustomComponents.order_block_delivery order={@order} drinks={@drinks} kontakt={@kontakt}/>
    <% end %>

      <div class="mb-28">
        <%= for food <- @foods do %>
          <%= if @selected_food && @selected_food.id == food.id do %>
            <CustomComponents.detailed_block food={@selected_food} quantity={@quantity_counter}/>
          <% else %>
            <CustomComponents.information_block food={food} />
          <% end %>
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
      <div id="play-sound-hook" phx-hook="PlaySound"></div>
    """
  end

  def handle_event("add_to_order", %{"id_food" => item_id, "quantity-input" => quantity, "ingredients" => selected_ingredients}, socket) do
    quantity = String.to_integer(quantity)
    item_id = String.to_integer(item_id)

    # Find if the item is a food or a drink
    food = Enum.find(socket.assigns.foods, fn food -> food.id == item_id end)
    drink = Enum.find(socket.assigns.drinks, fn drink -> drink.id == item_id end)

    cond do
      food ->
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
        socket = push_event(socket, "play_sound", %{"sound" => "sounds/prehodi/ka-ching.mp3"})
        {:noreply, assign(socket, order: updated_order, selected_food: nil, quantity_counter: 1)}

      drink ->
        updated_drink = Map.put(drink, :quantity, quantity)

        updated_order =
          socket.assigns.order
          |> Map.update(:drinks, %{}, fn drinks ->
            Map.update(drinks, drink.id, updated_drink, fn existing ->
              %{existing | quantity: existing.quantity + quantity}
            end)
          end)
          |> Map.update(:total_price, 0, &(&1 + (drink.price * quantity)))
        socket = push_event(socket, "play_sound", %{"sound" => "sounds/prehodi/ka-ching.mp3"})
        {:noreply, assign(socket, order: updated_order, selected_drink: nil, quantity_counter: 1, pijaca: false)}

      true ->
        {:noreply, socket} # If neither food nor drink is found, do nothing
    end
  end

  def handle_event("quantity_change", %{"direction" => direction}, socket) do

    socket = push_event(socket, "play_sound", %{"sound" => "sounds/prehodi/quantity.mp3"})
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

    socket = push_event(socket, "update_quantity", %{"quantity" => quantity})

    {:noreply, assign(socket, quantity_counter: quantity)}
  end

  def handle_event("ingredient_sounds", %{"sound" => sound}, socket) do
    {:noreply, socket |> push_event("play_sound", %{"sound" => sound})}
  end

  def handle_event("show_modal_pijaca", %{"drink_id" => drink_id}, socket) do
    socket = push_event(socket, "play_sound", %{"sound" => "sounds/prehodi/sirena.mp3"})
    selected_drink = Enum.find(socket.assigns.drinks, fn drink -> drink.id == String.to_integer(drink_id) end)
    {:noreply, assign(socket, pijaca: true, selected_drink: selected_drink)}
  end

  def handle_event("close_modal_pijaca", _params, socket) do
    {:noreply, assign(socket, pijaca: false, selected_drink: nil)}
  end

  def handle_event("show_modal_cebula", _params, socket) do
    socket = push_event(socket, "play_sound", %{"sound" => "sounds/sestavine/cebula.mp3"})
    {:noreply, assign(socket, :cebula_modal, true)}
  end

  def handle_event("show_modal_cebula", _params, socket) do
    {:noreply, assign(socket, :cebula_modal, true)}
  end

  def handle_event("close_modal_cebula", _params, socket) do
    {:noreply, assign(socket, :cebula_modal, false)}
  end

  # Handle event for caneling food order in detailed view of the food
  def handle_event("cancle_order", _params, socket) do
    {:noreply, assign(socket, :selected_food, nil)}
  end

  #Handle event for finishing the order. Displaying review of the order
  def handle_event("finish_order", _params, socket) do
    socket = push_event(socket, "play_sound", %{"sound" => "sounds/prehodi/pivo.mp3"})
    socket= assign(socket, :order_view, true)
    {:noreply, socket}
  end

  def handle_event("close_order_view", _params, socket) do
    socket= assign(socket, :order_view, false)
    {:noreply, socket}
  end

  # Handle event for confirming the order. FINAL STEP
  def handle_event("confirm_order", _params, socket) do
    order_number = -1

    order = transform_order(socket.assigns.order, order_number)

    PubSub.broadcast(FoodOrdering.PubSub, @topic, {:new_order, order})

    Menu.create_order_delivery(socket.assigns.order, order_number, socket.assigns.kontakt)

    socket= assign(socket, order_view: false, order: %{:food => %{}, :total_price => 0}, kontakt: %{}, loading: true)

    socket = push_event(socket, "play_sound", %{"sound" => "sounds/konec/konec.mp3"})

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

    socket = push_event(socket, "play_sound", %{"sound" => "sounds/prehodi/bo.mp3"})

    {:noreply, assign(socket, order: updated_order)}
  end

  # Handle event for selecting more information about the food. From informational view to detailed view
  def handle_event("select_more", %{"id" => food_id, "sound" => sound}, socket) do
    selected_food = Enum.find(socket.assigns.foods, fn food -> food.id == String.to_integer(food_id) end)

    socket = push_event(socket, "play_sound", %{"sound" => sound})

    {:noreply, assign(socket, selected_food: selected_food)}
  end

  def handle_event("remove_welcome", _parans, socket) do
    socket = push_event(socket, "play_sound", %{"sound" => "sounds/prehodi/kozarc.mp3"})
    {:noreply, assign(socket, welcome_block: false)}
  end

  def handle_event("show_kontakt", _params, socket) do
    {:noreply, assign(socket, kontakt_view: true)}
  end

  def handle_event("hide_kontakt", _params, socket) do
    {:noreply, assign(socket, kontakt_view: false)}
  end

  def handle_event("save_kontakt_data", %{"address" => addres, "name" => name, "phone" => phone, "surename" => surename}, socket) do
    kontakt=%{
      address: addres,
      ime: name,
      priimek: surename,
      phone: phone
    }
    {:noreply, assign(socket, kontakt: kontakt, kontakt_view: false)}
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
