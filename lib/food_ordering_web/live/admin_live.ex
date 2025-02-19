defmodule FoodOrderingWeb.AdminLive do
  use FoodOrderingWeb, :live_view

  alias FoodOrdering.Menu

  alias Escpos.Commands.{Text, TextFormat}
  alias Escpos.Printer

  @total_pagers 16

  def mount(_params, _session, socket) do
    reserved_pagers = Menu.get_reserved_pagers()

    pagers =
      Enum.map(1..@total_pagers, fn pager ->
        case Enum.find(reserved_pagers, fn {num, _} -> num == pager end) do
          nil -> %{order_number: pager, status: :available, expires_at: nil}
          {_, expires_at} -> %{order_number: pager, status: :reserved, expires_at: expires_at}
        end
      end)

    sales = Menu.list_sales()
    remaining_paper = Menu.get_remaining_paper()
    delivery_orders = Menu.get_delivery_orders()

    {:ok, assign(socket, pagers: pagers, sales: sales, remaining_paper: remaining_paper, orders: delivery_orders)}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto p-6">
      <h1 class="text-2xl font-bold mb-4">Admin Dashboard</h1>

      <div class="bg-white shadow-md rounded-lg p-4 mb-6">
        <h2 class="text-xl font-semibold mb-2">Orders for delivery</h2>
        <div class="grid grid-cols-3 gap-4 ">
          <%= for order <- @orders do %>
            <div class="p-4 text-lefft rounded-lg shadow-md font-semibold">
              <p>Ime: <%= order.ime %></p>
              <p>Naslov: <%= order.address %></p>
              <p>Cena: <%= order.total_price%></p>

              <button phx-click="print_delivery_order" phx-value-order_id={order.id} class="bg-blue-500 text-white px-2 py-2 mt-2 rounded">
                Natisni račin
              </button>
            </div>

          <% end %>
        </div>
      </div>



      <!-- Sales Statistics -->
      <div class="bg-white shadow-md rounded-lg p-4 mb-6">
        <h2 class="text-xl font-semibold mb-2">Sales Statistics</h2>
        <table class="w-full border-collapse border border-gray-300">
          <thead>
            <tr class="bg-gray-200">
              <th class="p-2 border">Food Item</th>
              <th class="p-2 border">Quantity Sold</th>
            </tr>
          </thead>
          <tbody>
            <%= for sale <- @sales do %>
              <tr class="text-center">
                <td class="p-2 border"><%= sale.food_name %></td>
                <td class="p-2 border"><%= sale.quantity_sold %></td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>

      <!-- Printer Paper Usage -->
      <div class="bg-white shadow-md rounded-lg p-4 mb-6">
        <div class="flex justify-between mb-2">
          <h2 class="text-xl font-semibold">Printer Paper Usage</h2>
          <button phx-click="refill_printer" class="bg-blue-500 text-white px-4 py-2 rounded">
            Refill printer
          </button>
        </div>
        <div class="relative w-full h-6 bg-gray-200 rounded-lg overflow-hidden">
          <div class="h-full bg-blue-500 transition-all duration-500"
               style={"width: #{@remaining_paper / 80.0 * 100}%"}></div>
        </div>
        <p class="mt-2 text-gray-700">Remaining Paper: <%= @remaining_paper %>m</p>
      </div>

      <div class="bg-white shadow-md rounded-lg p-4 mb-6">
        <h1 class="text-2xl font-bold mb-4">Pagers Status</h1>
        <div class="grid grid-cols-4 gap-4">
          <%= for pager <- @pagers do %>
            <div class={"p-4 text-center rounded-lg shadow-md font-semibold " <>
                        (if pager.status == :reserved, do: "bg-red-500 text-white", else: "bg-green-500 text-white")}>
              <p>Pager <%= pager.order_number %></p>
              <%= if pager.status == :reserved do %>
                <p class="text-sm opacity-80">Reserved until: <%= pager.expires_at %></p>
              <% else %>
                <p class="text-sm opacity-80">Available</p>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>

      <button phx-click="delete_all_images" class="bg-red-500 text-white px-4 py-2 rounded">
        Delete All Images
      </button>

      <button phx-click="delete_all_orders" class="bg-red-500 text-white px-4 py-2 rounded">
        Delete All Orders
      </button>

    </div>
    """
  end

  def handle_event("delete_all_images", _params, socket) do
    folder_path = Path.join(:code.priv_dir(:food_ordering), "static/images/dashboard")

    files_deleted =
      folder_path
      |> File.ls!()
      |> Enum.filter(&Regex.match?(~r/\.(png|jpg)$/, &1))
      |> Enum.map(&File.rm(Path.join(folder_path, &1)))

    # Provide feedback
    case Enum.all?(files_deleted, &(&1 == :ok)) do
      true -> {:noreply, put_flash(socket, :info, "All images deleted successfully.")}
      false -> {:noreply, put_flash(socket, :error, "Some images could not be deleted.")}
    end
  end

  def handle_event("delete_all_orders", __params, socket) do
    Menu.delete_orders()
    {:noreply, socket}
  end

  def handle_event("refill_printer", _params, socket) do
    Menu.reset_paper()
    {:noreply, assign(socket, :remaining_paper, 80.0)}
  end

  def handle_event("print_delivery_order", %{"order_id" => id}, socket) do
    order = Menu.get_order(id)

    order_transformed = transform_order(order)

    case Printer.from_usb(0x1504, 0x001d) do
      {:ok, %Printer{} = p} ->
        IO.puts("Printer connected successfully!")
        print_receipt(p, order)
        Menu.use_paper()
        {:ok, p}

      {:error, :device_not_found} ->
        IO.puts("Error: Printer not found. Please check the connection.")
        :error
    end

    {:noreply, put_flash(socket, :info, "Printanje...")}
  end

  defp print_receipt(printer_handle, order) do
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
      "DOSTAVA TOMBA\n" |> to_string(),
      TextFormat.txt_normal(),
      TextFormat.txt_align_lt(),
      TextFormat.txt_bold_off(),
      "----------------------\n" |> to_string()
    ] ++
    List.flatten(Enum.map(order_items, &format_item/1)) ++  # Ensure flattened list
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

  defp format_item(%{food: %{name: name}, customizations: %{"ingredients" => ingredients, "quantity" => quantity}}) do
    [
      TextFormat.txt_bold_on(),
      "#{quantity}x #{name}\n" |> to_string(),
      TextFormat.txt_bold_off(),
      Enum.map(ingredients, fn ingredient -> "- #{ingredient}\n" |> to_string() end)
    ]
    |> List.flatten()
  end

  def transform_order(order) do
    %FoodOrdering.Foods.Order{
      total_price: total_price,
      order_items: order_items
    } = order

    status = "Pending"

    order_items_transformed =
      order_items
      |> Enum.map(fn %FoodOrdering.Foods.OrderItem{food: food, customizations: customizations} ->
        %{
          food: %{
            name: food.name
          },
          customizations: %{
            "quantity" => customizations["quantity"],
            "ingredients" => customizations["ingredients"]
          }
        }
      end)

    %{
      status: status,
      total_price: total_price,
      order_items: order_items_transformed
    }
  end

end
