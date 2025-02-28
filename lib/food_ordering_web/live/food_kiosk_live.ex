defmodule FoodOrderingWeb.FoodKioskLive do
  use FoodOrderingWeb, :live_view
  alias FoodOrderingWeb.CustomComponents
  alias Phoenix.PubSub
  require Integer

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

    IO.inspect(drinks)

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
     |> assign(:drink, nil)}
  end

  def render(assigns) do
    ~H"""
    <%= if @welcome_block==true do %>
      <CustomComponents.welcome_block />
    <% end %>

    <%= if @loading==true do %>
      <CustomComponents.loading_block />
    <% end %>

    <%= if @cebula_modal==true do %>
      <CustomComponents.cebula_modal />
    <% end %>

    <%= if @pijaca==true do %>
      <CustomComponents.pijaca_modal drink={@selected_drink}/>
    <% end %>

    <%= if @order_view do %>
      <CustomComponents.order_block order={@order} drinks={@drinks}/>
    <% end %>
    <div class="mx-auto max-w-2xl">
      <div class="mb-28">
        <%= for food <- @foods do %>
            <%= if @selected_food && @selected_food.id == food.id do %>
              <CustomComponents.detailed_block food={@selected_food} quantity={@quantity_counter}/>
            <% else %>
              <CustomComponents.information_block food={food}/>
            <% end %>
        <% end %>
      </div>
      <footer class="fixed bottom-0 left-0 z-20 w-full bg-white border-t border-gray-200 shadow-sm flex items-center justify-between p-6">
        <span class="text-3xl font-medium text-gray-900 sm:text-center"> Cena: <%= Map.get(@order, :total_price) %> €</span>
        <ul class="flex flex-wrap items-center text-2xl font-medium text-white bg-blue-700 rounded-lg p-5">
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
    IO.inspect(drink)
    IO.inspect(quantity)
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

  def handle_event("show_modal_cebula", _params, socket) do
    socket = push_event(socket, "play_sound", %{"sound" => "sounds/sestavine/cebula.mp3"})
    {:noreply, assign(socket, :cebula_modal, true)}
  end

  def handle_event("close_modal_cebula", _params, socket) do
    {:noreply, assign(socket, :cebula_modal, false)}
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
    case Menu.generate_unique_order_number() do
      {:ok, order_number} ->
        IO.inspect(socket.assigns.order)
        IO.inspect(order_number)

        Menu.record_sale(socket.assigns.order)

        IO.inspect(socket.assigns.order)
        order = transform_order(socket.assigns.order, order_number)



        case Printer.from_usb(0x1504, 0x001d) do
          {:ok, %Printer{} = p} ->
            IO.puts("Printer connected successfully!")
            print_receipt(p, order)
            Menu.use_paper()
            {:ok, p}

          {:error, :device_not_found} ->
            Menu.use_paper()
            IO.puts("Error: Printer not found. Please check the connection.")
            :error
        end

        PubSub.broadcast(FoodOrdering.PubSub, @topic, {:new_order, order})

        Menu.create_order(socket.assigns.order, order_number)

        socket= assign(socket, order_view: false, order: %{:food => %{}, :total_price => 0}, loading: true)

        socket = push_event(socket, "play_sound", %{"sound" => "sounds/konec/konec.mp3"})

        {:noreply, socket}

      {:error, :no_available_pagers} ->
        IO.puts("No available order numbers!")
        {:noreply, socket}
    end
  end

  def handle_event("remove_from_order", %{"id" => food_id}, socket) do
    food = Enum.find(socket.assigns.foods, fn food -> food.id == String.to_integer(food_id) end)

    {key, food_entry} =
      socket.assigns.order.food
      |> Enum.find(fn {{id, _}, _} -> id == food.id end)

    quantity = food_entry.quantity

    updated_order =
      socket.assigns.order
      |> Map.update(:food, %{}, fn foods ->
        Map.delete(foods, key)
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

  def handle_event("upload_image", %{"image" => image_data}, socket) do
    case Regex.run(~r/data:image\/(png|jpeg);base64,/, image_data) do
      [_, format] ->
        base64_data = String.replace(image_data, ~r/data:image\/(png|jpeg);base64,/, "")

        case Base.decode64(base64_data) do
          {:ok, binary} ->
            timestamp = :os.system_time(:millisecond)
            extension = if format == "jpeg", do: "jpg", else: "png"
            filename = "image_#{timestamp}.#{extension}"

            uploads_dir = "uploads/dashboard"
            File.mkdir_p!(uploads_dir)
            File.write!(Path.join(uploads_dir, filename), binary)

            {:noreply, socket |> push_redirect(to: socket.assigns.live_action)}

          :error ->
            {:noreply, put_flash(socket, :error, "Invalid image data")}
        end

      nil ->
        {:noreply, put_flash(socket, :error, "Invalid image format")}
    end
  end

  defp print_receipt(printer_handle, order) do
    IO.inspect(order)
    order_number = order.order_number
    total_price = order.total_price
    order_items = order.order_items

    data = [
      "                    |                \n" |> to_string(),
      "                                     \n" |> to_string(),
      "                    |                \n" |> to_string(),
      "                                     \n" |> to_string(),
      "                    |                \n" |> to_string(),
      "                                     \n" |> to_string(),
      "                    |                \n" |> to_string(),
      "                                     \n" |> to_string(),
      "                    |                \n" |> to_string(),
      "                                     \n" |> to_string(),
      "                    |                \n" |> to_string(),
      "            ----------------         \n" |> to_string(),
      "          /         |        \       \n" |> to_string(),
      "         /          |         \      \n" |> to_string(),
      "         |          |         |      \n" |> to_string(),
      "         |                    |      \n" |> to_string(),
      "         |                    |      \n" |> to_string(),
      "          \                  /       \n" |> to_string(),
      "           \                /        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "           |                |        \n" |> to_string(),
      "     -------                -------  \n" |> to_string(),
      "    |              .             . | \n" |> to_string(),
      "    |   .    .         .   .       | \n" |> to_string(),
      "    |                          .   | \n" |> to_string(),
      "    |   .      .     |             | \n" |> to_string(),
      "    |            .   | .     .     | \n" |> to_string(),
      "    -------------------------------| \n" |> to_string(),
      "\n\n\n\n" |> to_string(),
      TextFormat.txt_4square(),
      TextFormat.txt_align_ct(),
      "TO NI RACUN\n" |> to_string(),
      TextFormat.txt_align_lt(),
      TextFormat.txt_normal(),
      "HU - ZPP\n" |> to_string(),
      "Mali Paris\n" |> to_string(),
      "Brez ID za DDV\n" |> to_string(),
      "Racun st. 4206969/01\n" |> to_string(),
      "2.3.2025 ob 13:05\n" |> to_string(),
      "\n\n" |> to_string(),
      "----------------------\n" |> to_string(),
      TextFormat.txt_bold_on(),
      TextFormat.txt_align_ct(),
      TextFormat.txt_4square(),
      "Piskac: #{order_number}\n" |> to_string(),
      TextFormat.txt_normal(),
      TextFormat.txt_align_lt(),
      TextFormat.txt_bold_off(),
      "----------------------\n" |> to_string()
    ] ++
    List.flatten(Enum.flat_map(order_items, &format_item/1)) ++
    [
      "----------------------\n" |> to_string(),
      TextFormat.txt_bold_on(),
      TextFormat.txt_4square(),
      "NANESE: #{total_price} EUR\n" |> to_string(),
      TextFormat.txt_normal(),
      TextFormat.txt_bold_off(),
      "----------------------\n" |> to_string(),
      "\n\n" |> to_string(),
      "Racun izdal KIOSK1 \n" |> to_string(),
      TextFormat.txt_bold_on(),
      "Placilo za jurckom \n" |> to_string(),
      TextFormat.txt_bold_off(),
      "Nacin placila: Gotovina \n" |> to_string(),
      "\n\n" |> to_string(),
      "V primeru da manjka WC papirja\n" |> to_string(),
      "uporabi ta papir\n" |> to_string(),
      "\n\n" |> to_string(),
      TextFormat.txt_4square(),
      "NAGRADNA IGRA\n" |> to_string(),
      TextFormat.txt_normal(),
      "Podpisi se in vrzi v\n" |> to_string(),
      Escpos.Commands.Paper.full_cut(),
      "zrebalni boben.\n" |> to_string(),
      "\n\n" |> to_string(),
      "\n\n\n" |> to_string(),
      "Ime in priimek\n" |> to_string(),
      "----------------------\n" |> to_string(),
      "\n\n\n\n" |> to_string(),
      "----------------------\n" |> to_string(),
      "\n\n\n\n\n\n" |> to_string(),
      Escpos.Commands.Paper.full_cut()
    ]

    Escpos.write(printer_handle, IO.iodata_to_binary(data))

    Printer.close(printer_handle)
  end

  defp format_item(%{food: food,drinks: drinks}) do
    food_items =
    case food do
      %{name: name, customizations: %{"ingredients" => ingredients, "quantity" => quantity}} ->
        [
          TextFormat.txt_bold_on(),
          "#{quantity}x #{name}\n",
          TextFormat.txt_bold_off(),
          Enum.map(ingredients, fn ingredient -> "- #{ingredient}\n" end)
        ]
        |> List.flatten()

      _ ->
        []
    end

    drink_items =
    drinks
    |> Map.values()
    |> Enum.map(fn %{name: name, quantity: quantity} ->
      "#{quantity}x #{name}\n"
    end)

    food_items ++ drink_items
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

end
