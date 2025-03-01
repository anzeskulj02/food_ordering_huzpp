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

  @api_host  "https://openapi.tuyaeu.com"
  @client_id "aqj9p7duyukga9g3eag7"       # Replace with your actual Client ID
  @secret "188224eb30a84daf86feda969be52e1e" # Replace with your actual Access Secret

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
    <div class="mx-auto max-w-2xl">
      <div class="mb-28">
        <%= for food <- @foods do %>
          <%= if @selected_food && @selected_food.id == food.id do %>
            <CustomComponents.detailed_block food={@selected_food} quantity={@quantity_counter}/>
          <% else %>
            <CustomComponents.information_block food={food} />
          <% end %>
        <% end %>
      </div>
      <footer class="fixed bottom-0 left-0 z-20 w-full bg-white border-t border-gray-200 shadow-sm flex items-center justify-between p-3">
        <span class="text-xl font-medium text-gray-900 sm:text-center"> Cena: <%= Map.get(@order, :total_price) %> €</span>
        <ul class="flex flex-wrap items-center text-lg font-medium text-white bg-blue-700 rounded-lg px-5 py-2.5">
            <li>
                <a phx-click="finish_order" class="hover:underline">Preglej naročilo</a>
            </li>
        </ul>
      </footer>
      <div id="play-sound-hook" phx-hook="PlaySound"></div>
    </div>
    """
  end

  def handle_event("add_to_order", %{"id_food" => item_id, "quantity-input" => quantity, "ingredients" => selected_ingredients}, socket) do
    quantity = String.to_integer(quantity)
    item_id = String.to_integer(item_id)

    food = Enum.find(socket.assigns.foods, fn food -> food.id == item_id end)
    drink = Enum.find(socket.assigns.drinks, fn drink -> drink.id == item_id end)

    cond do
      food ->
        selected_ingredients = List.wrap(selected_ingredients) |> Enum.sort() # Ensure it's always a list
        unique_key = {food.id, selected_ingredients} # Unique key with sorted ingredients

        updated_food = %{
          id: food.id,
          name: food.name,
          price: food.price,
          quantity: quantity,
          ingredients: selected_ingredients
        }

        updated_order =
          socket.assigns.order
          |> Map.update(:food, %{}, fn foods ->
            Map.update(foods, unique_key, updated_food, fn existing ->
              %{existing | quantity: existing.quantity + quantity}
            end)
          end)
          |> Map.update(:total_price, 0, &(&1 + (food.price * quantity)))

        socket = push_event(socket, "play_sound", %{"sound" => "sounds/prehodi/ka-ching.mp3"})
        {:noreply, assign(socket, order: updated_order, selected_food: nil, quantity_counter: 1)}

      drink ->
        token = request_token()
        send_command(token, %{"code" => "switch_1", "value" => false})
        updated_drink = %{
          id: drink.id,
          quantity: quantity,
          name: drink.name,
          slug: drink.slug,
          price: drink.price
        }


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
        {:noreply, socket}
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
    token = request_token()
    send_command(token, %{"code" => "switch_1", "value" => true})
    socket = push_event(socket, "play_sound", %{"sound" => "sounds/prehodi/sirena.mp3"})
    selected_drink = Enum.find(socket.assigns.drinks, fn drink -> drink.id == String.to_integer(drink_id) end)
    {:noreply, assign(socket, pijaca: true, selected_drink: selected_drink)}
  end

  def handle_event("close_modal_pijaca", _params, socket) do
    token = request_token()
    send_command(token, %{"code" => "switch_1", "value" => false})
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

    target_path = socket.assigns.live_action || "/"
    {:noreply, socket |> push_redirect(to: target_path)}
  end

  def handle_event("remove_from_order", %{"id" => item_id}, socket) do
    item_id = String.to_integer(item_id)

    food = Enum.find(socket.assigns.foods, fn food -> food.id == item_id end)
    drink = Enum.find(socket.assigns.drinks, fn drink -> drink.id == item_id end)

    cond do
      food ->
        case Enum.find(socket.assigns.order.food, fn {{id, _}, _} -> id == food.id end) do
          {key, food_entry} ->
            quantity = food_entry.quantity

            updated_order =
              socket.assigns.order
              |> Map.update(:food, %{}, fn foods -> Map.delete(foods, key) end)
              |> Map.update(:total_price, 0, &(&1 - (food.price * quantity)))

            socket = push_event(socket, "play_sound", %{"sound" => "sounds/prehodi/bo.mp3"})
            {:noreply, assign(socket, order: updated_order)}

          nil ->
            {:noreply, socket} # Food not found in order, do nothing
        end

      drink ->
        case Map.get(socket.assigns.order.drinks, drink.id) do
          nil ->
            {:noreply, socket} # Drink not found, do nothing

          %{quantity: quantity} = drink_entry ->
            updated_order =
              socket.assigns.order
              |> Map.update(:drinks, %{}, fn drinks -> Map.delete(drinks, drink.id) end)
              |> Map.update(:total_price, 0, &(&1 - (drink.price * quantity)))

            socket = push_event(socket, "play_sound", %{"sound" => "sounds/prehodi/bo.mp3"})
            {:noreply, assign(socket, order: updated_order)}
        end

      true ->
        {:noreply, socket}
    end
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

  def get_timestamp do
    :os.system_time(:millisecond) |> Integer.to_string()
  end

  def generate_nonce do
    UUID.uuid4()
  end

  def generate_string_to_sign(method, query, body, headers, url) do
    sha256_hash = :crypto.hash(:sha256, body || "")
                  |> Base.encode16(case: :lower)

    headers_str =
      if Map.has_key?(headers, "Signature-Headers") do
        headers["Signature-Headers"]
        |> String.split(":")
        |> Enum.map(fn key ->
          value = Map.get(headers, key, "")
          "#{key}:#{value}\n"
        end)
        |> Enum.join("")
      else
        ""
      end

    sorted_query =
      query
      |> URI.encode_query()
      |> (fn str -> if str != "", do: "?#{str}", else: "" end).()

    full_url = "#{url}#{sorted_query}"

    sign_string = "#{method}\n#{sha256_hash}\n#{headers_str}\n#{full_url}"

    {sign_string, full_url}
  end

  def generate_sign(client_id, timestamp, nonce, sign_string, secret) do
    sign_data = client_id <> timestamp <> nonce <> sign_string

    :crypto.mac(:hmac, :sha256, secret, sign_data)
    |> Base.encode16(case: :upper)
  end

  def request_token() do
    timestamp = get_timestamp()
    nonce = generate_nonce()
    method = "GET"
    query = %{"grant_type" => "1"}
    url = "/v1.0/token"

    headers = %{
      "client_id" => @client_id,
      "t" => timestamp,
      "nonce" => nonce,
      "sign_method" => "HMAC-SHA256"
    }

    {sign_string, full_url} = generate_string_to_sign(method, query, "", headers, url)

    sign = generate_sign(@client_id, timestamp, nonce, sign_string, @secret)

    headers = Map.put(headers, "sign", sign)

    response =
      Req.get!(
        "https://openapi.tuyaeu.com#{full_url}",
        headers: headers
      )

    response.body["result"]["access_token"]
  end

  def generate_sign_command(client_id, access_token, timestamp, nonce, sign_string, secret) do
    sign_data = client_id <> access_token <> timestamp <> nonce <> sign_string

    :crypto.mac(:hmac, :sha256, secret, sign_data)
    |> Base.encode16(case: :upper)
  end

  def send_command(access_token, command) do
    device_id="5014640498f4abdd667f"
    timestamp = get_timestamp()
    nonce = generate_nonce()
    method = "POST"
    url = "/v1.0/devices/#{device_id}/commands"
    body = Jason.encode!(%{"commands" => [command]})

    headers = %{
      "client_id" => @client_id,
      "access_token" => access_token,
      "t" => timestamp,
      "nonce" => nonce,
      "sign_method" => "HMAC-SHA256",
      "Content-Type" => "application/json"
    }

    {sign_string, full_url} = generate_string_to_sign(method, %{}, body, headers, url)
    sign = generate_sign_command(@client_id, access_token, timestamp, nonce, sign_string, @secret)
    headers = Map.put(headers, "sign", sign)
    IO.inspect(headers)
    IO.inspect(command)
    response =
      Req.post!(
        "https://openapi.tuyaeu.com#{full_url}",
        headers: headers,
        json: %{commands: [command]}
      )

    IO.inspect(response)
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
