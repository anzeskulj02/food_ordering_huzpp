defmodule FoodOrderingWeb.FoodDashboard do
  use FoodOrderingWeb, :live_view
  alias FoodOrderingWeb.CustomComponents
  alias FoodOrdering.Menu

  alias Phoenix.PubSub

  @topic "food_orders"

  def mount(_params, _session, socket) do
    if connected?(socket), do: PubSub.subscribe(FoodOrdering.PubSub, @topic)

    orders  = Menu.list_pending_orders()

    {:ok, assign(socket, :orders, orders)}
  end

  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-3 gap-4 p-4">
      <%= for order <- @orders do %>
        <%= if order.order_number < 0 do %>
          <div class="border rounded-lg p-3 bg-blue-300">
            <div class="flex justify-between">
              <p class="mt-2 text-lg font-medium"><%= order.order_number %> (DOSTAVA)</p>
              <p class="mt-2 text-lg text-center"><%= order.status %></p>
              <!--<p class="mt-2 text-base text-center"><%= order.total_price %> €</p>-->
            </div>

              <%= for food <- order.order_items do %>
                <div class="flex mt-4">
                  <p class="mt-2 text-lg"><%= food.food.name %></p>
                  <p class="mt-2 ml-4 text-lg"><%= food.customizations["quantity"] %> X</p>

                </div>
                <%= for ingredient <- food.customizations["ingredients"] do %>
                  <p class="ml-3 text-base"><%= ingredient %></p>
                <% end %>
              <% end %>
          </div>
        <% else %>
          <div class="border rounded-lg p-3">
            <div class="flex justify-between">
              <p class="mt-2 text-lg font-medium"><%= order.order_number %></p>
              <p class="mt-2 text-lg text-center"><%= order.status %></p>
              <!--<p class="mt-2 text-base text-center"><%= order.total_price %> €</p>-->
            </div>

              <%= for food <- order.order_items do %>
                <div class="flex mt-4">
                  <p class="mt-2 text-lg"><%= food.food.name %></p>
                  <p class="mt-2 ml-4 text-lg"><%= food.customizations["quantity"] %> X</p>

                </div>
                <%= for ingredient <- food.customizations["ingredients"] do %>
                  <p class="ml-3 text-base"><%= ingredient %></p>
                <% end %>
              <% end %>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  def handle_info({:new_order, order}, socket) do
    {:noreply, update(socket, :orders, fn orders -> [order | orders] end)}
  end
end
