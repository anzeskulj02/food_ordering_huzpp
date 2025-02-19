defmodule FoodOrderingWeb.CustomComponents do
  use Phoenix.Component

  attr :food, :map, required: true, doc: "food information"
  def information_block(assigns) do
    ~H"""
      <div class={"w-full my-10 bg-white border border-gray-200 rounded-lg shadow-sm #{if @food.slug == "klapavice" do "opacity-70 grayscale pointer-events-none" end}"}>
        <%= if @food.slug == "klapavice" do %>
          <div class="absolute inset-0 flex items-center justify-center bg-gray-700 bg-opacity-30 text-white text-3xl font-bold rounded-lg">Razprodano</div>
        <% end %>
        <a href="#" phx-click="select_more" phx-value-id={@food.id} phx-value-sound={"sounds/izbera_hrane/#{@food.slug}.mp3"}><img class="p-8 px-5 mx-auto rounded-lg" src={"/images/food_images/#{@food.slug}.jpg"} alt="product image"/></a>
        <div class="px-5 pb-5">
          <a href="#">
              <h5 class="text-3xl font-bold text-gray-900"><%= @food.name %></h5>
          </a>
          <div class="flex items-center mt-2.5 mb-5">
              <div class="flex items-center space-x-1 rtl:space-x-reverse">
                  <svg class="w-4 h-4 text-yellow-300" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 22 20">
                      <path d="M20.924 7.625a1.523 1.523 0 0 0-1.238-1.044l-5.051-.734-2.259-4.577a1.534 1.534 0 0 0-2.752 0L7.365 5.847l-5.051.734A1.535 1.535 0 0 0 1.463 9.2l3.656 3.563-.863 5.031a1.532 1.532 0 0 0 2.226 1.616L11 17.033l4.518 2.375a1.534 1.534 0 0 0 2.226-1.617l-.863-5.03L20.537 9.2a1.523 1.523 0 0 0 .387-1.575Z"/>
                  </svg>
                  <svg class="w-4 h-4 text-yellow-300" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 22 20">
                      <path d="M20.924 7.625a1.523 1.523 0 0 0-1.238-1.044l-5.051-.734-2.259-4.577a1.534 1.534 0 0 0-2.752 0L7.365 5.847l-5.051.734A1.535 1.535 0 0 0 1.463 9.2l3.656 3.563-.863 5.031a1.532 1.532 0 0 0 2.226 1.616L11 17.033l4.518 2.375a1.534 1.534 0 0 0 2.226-1.617l-.863-5.03L20.537 9.2a1.523 1.523 0 0 0 .387-1.575Z"/>
                  </svg>
                  <svg class="w-4 h-4 text-yellow-300" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 22 20">
                      <path d="M20.924 7.625a1.523 1.523 0 0 0-1.238-1.044l-5.051-.734-2.259-4.577a1.534 1.534 0 0 0-2.752 0L7.365 5.847l-5.051.734A1.535 1.535 0 0 0 1.463 9.2l3.656 3.563-.863 5.031a1.532 1.532 0 0 0 2.226 1.616L11 17.033l4.518 2.375a1.534 1.534 0 0 0 2.226-1.617l-.863-5.03L20.537 9.2a1.523 1.523 0 0 0 .387-1.575Z"/>
                  </svg>
                  <svg class="w-4 h-4 text-yellow-300" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 22 20">
                      <path d="M20.924 7.625a1.523 1.523 0 0 0-1.238-1.044l-5.051-.734-2.259-4.577a1.534 1.534 0 0 0-2.752 0L7.365 5.847l-5.051.734A1.535 1.535 0 0 0 1.463 9.2l3.656 3.563-.863 5.031a1.532 1.532 0 0 0 2.226 1.616L11 17.033l4.518 2.375a1.534 1.534 0 0 0 2.226-1.617l-.863-5.03L20.537 9.2a1.523 1.523 0 0 0 .387-1.575Z"/>
                  </svg>
                  <svg class="w-4 h-4 text-gray-200 dark:text-gray-600" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 22 20">
                      <path d="M20.924 7.625a1.523 1.523 0 0 0-1.238-1.044l-5.051-.734-2.259-4.577a1.534 1.534 0 0 0-2.752 0L7.365 5.847l-5.051.734A1.535 1.535 0 0 0 1.463 9.2l3.656 3.563-.863 5.031a1.532 1.532 0 0 0 2.226 1.616L11 17.033l4.518 2.375a1.534 1.534 0 0 0 2.226-1.617l-.863-5.03L20.537 9.2a1.523 1.523 0 0 0 .387-1.575Z"/>
                  </svg>
              </div>
              <span class="bg-blue-100 text-blue-800 text-xs font-semibold px-2.5 py-0.5 rounded-sm ms-3">5.0</span>
          </div>
          <div class="flex items-center justify-between">
              <span class="text-3xl font-bold text-gray-900"><%= @food.price %> €</span>
              <a href="#" phx-click="select_more" phx-value-id={@food.id} phx-value-sound={"sounds/izbera_hrane/#{@food.slug}.mp3"} class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center">Izberi</a>
          </div>
        </div>
      </div>
    """
  end

  attr :food, :map, required: true, doc: "food information"
  attr :quantity, :integer, required: true, doc: "quantity of food"
  def detailed_block(assigns) do
    ~H"""
      <div class="fixed inset-0 z-30 flex flex-col bg-white p-3 px-5 sm:p-5 sm:px-10 shadow-lg">
        <div class="flex gap-3 sm:gap-5">
          <div class="w-1/3 flex items-center">
            <img class="w-full h-full rounded-lg" src={"/images/food_images/#{@food.slug}.jpg"} alt="product image"/>
          </div>
          <div class="w-2/3 flex flex-col justify-between">
            <h2 class="text-base sm:text-2xl font-bold"><%= @food.name %></h2>
            <p class="text-xs sm:text-lg text-gray-600"><%= @food.description %></p>
            <p class="text-lg sm:text-2xl font-bold text-gray-900">$<%= @food.price %></p>
          </div>
        </div>

        <form id="detailed_block_form" phx-submit="add_to_order" phx-update="ignore" class="flex flex-col flex-1 mt-3 sm:mt-5">
          <div class="flex-1">
            <h2 class="text-sm sm:text-xl font-medium">Odstrani sestavine:</h2>
            <ul class="grid w-full gap-3 sm:gap-6 grid-cols-2 sm:grid-cols-3 mt-2 sm:mt-5 max-h-[40vh] overflow-y-auto">
              <%= for ingredient <- @food.ingredients do %>
                <li phx-click={if ingredient.slug == "cebula", do: "show_modal_cebula", else: "ingredient_sounds"}
                    phx-value-sound={"sounds/sestavine/#{ingredient.slug}.mp3"}>
                  <input type="checkbox"
                        id={ingredient.slug}
                        name="ingredients[]"
                        value={ingredient.name}
                        class="hidden peer"
                        checked>
                  <label for={ingredient.slug} class="inline-flex flex-col items-center w-full p-2 text-gray-500 bg-white border-2 border-gray-200 rounded-lg cursor-pointer peer-checked:border-blue-600 hover:text-gray-600 peer-checked:text-gray-600 hover:bg-gray-50">
                    <img src={"images/sestavine/#{ingredient.slug}.png"} alt="Flag" class="w-14 h-14 sm:w-20 sm:h-20 object-contain mx-auto"/>
                    <div class="text-xs sm:text-lg font-semibold mt-2 sm:mt-3 text-center"><%= ingredient.name %></div>
                  </label>
                </li>
              <% end %>
            </ul>
          </div>

          <div class="mt-3 sm:mt-10">
            <h2 class="text-sm sm:text-xl font-medium">Izberi količino:</h2>
            <input type="hidden" name="id_food" value={@food.id} />
            <div class="relative flex items-center max-w-[8rem] sm:max-w-[15rem] mt-2 sm:mt-5">
              <button type="button" id="decrement-button" phx-click="quantity_change" phx-value-direction="decrement"
                      class="bg-gray-100 hover:bg-gray-200 border border-gray-300 text-lg rounded-s-lg p-2 sm:p-3 h-9 sm:h-16">
                <svg class="w-4 h-4 sm:w-6 sm:h-6 text-gray-900" viewBox="0 0 18 2">
                  <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 1h16"/>
                </svg>
              </button>
              <input type="text" phx-hook="QuantityUpdater" value={@quantity} name="quantity-input" id="quantity-input"
                    class="bg-gray-50 border-x-0 border-gray-300 h-9 sm:h-16 text-center text-gray-900 text-lg sm:text-xl w-full py-2.5"
                    required/>
              <button type="button" id="increment-button" phx-click="quantity_change" phx-value-direction="increment"
                      class="bg-gray-100 hover:bg-gray-200 border border-gray-300 text-lg rounded-e-lg p-2 sm:p-3 h-9 sm:h-16">
                <svg class="w-4 h-4 sm:w-6 sm:h-6 text-gray-900" viewBox="0 0 18 18">
                  <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 1v16M1 9h16"/>
                </svg>
              </button>
            </div>
          </div>

          <div class="mt-auto">
            <button type="submit"
                    class="mt-5 w-full text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-lg px-10 py-4">
              Potrdi
            </button>
          </div>
        </form>
        <button phx-click="cancle_order"
                class="mt-3 w-full text-white bg-red-700 hover:bg-red-800 focus:ring-4 focus:outline-none focus:ring-red-300 font-medium rounded-lg text-lg px-10 py-4">
          Zavrzi
        </button>

      </div>

    """
  end

  attr :order, :map, required: true, doc: "order information"
  attr :drinks, :list, required: true, doc: "list of drinks"
  def order_block(assigns) do
    ~H"""
      <div class="fixed inset-0 z-30 flex flex-col bg-white shadow-lg overflow-auto">
        <div class="flex justify-between items-center px-4 sm:px-5">
          <div>
            <h2 class="text-lg sm:text-3xl mt-6 sm:mt-10 font-bold">Preglej naročilo</h2>
            <p class="text-sm sm:text-xl text-gray-600">Kasnejših reklamacij ne upoštevamo</p>
          </div>
          <button type="button" phx-click="close_order_view" class="text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-base sm:text-lg w-8 h-8 sm:w-10 sm:h-10 flex justify-center items-center" data-modal-hide="default-modal">
            <svg class="w-5 h-5 sm:w-6 sm:h-6" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 14">
              <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"/>
            </svg>
            <span class="sr-only">Zapri</span>
          </button>
        </div>

        <div class="relative overflow-x-auto sm:rounded-lg mt-6 sm:mt-10 flex-1 min-h-0">
          <table class="w-full text-xs sm:text-sm text-left text-gray-500">
            <thead class="text-xs text-gray-700 uppercase bg-gray-50">
              <tr>
                <th scope="col" class="px-3 sm:px-6 py-2 sm:py-3">Hrana</th>
                <th scope="col" class="px-3 sm:px-6 py-2 sm:py-3">Količina</th>
                <th scope="col" class="px-3 sm:px-6 py-2 sm:py-3">Sestavine</th>
                <th scope="col" class="px-3 sm:px-6 py-2 sm:py-3">Cena</th>
                <th scope="col" class="px-3 sm:px-6 py-2 sm:py-3"></th>
              </tr>
            </thead>
            <tbody>
              <%= for {_id, food} <- @order.food do %>
                <tr class="odd:bg-white even:bg-gray-50 border-b border-gray-200">
                  <th scope="row" class="px-3 sm:px-6 py-2 sm:py-4 font-medium text-gray-900 whitespace-nowrap">
                    <%= food.name %>
                  </th>
                  <td class="px-3 sm:px-6 py-2 sm:py-4">
                    <%= food.quantity %>
                  </td>
                  <td class="px-3 sm:px-6 py-2 sm:py-4">
                    <%= Enum.join(food.ingredients, ", ") %>
                  </td>
                  <td class="px-3 sm:px-6 py-2 sm:py-4">
                    <%= food.price %> €
                  </td>
                  <td class="px-3 sm:px-6 py-2 sm:py-4">
                    <button phx-click="remove_from_order" phx-value-id={food.id} class="text-red-600 hover:underline">Odstrani</button>
                  </td>
                </tr>
              <% end %>

              <%= for {_id, drink} <- @order.drinks do %>
                <tr class="odd:bg-white even:bg-gray-50 border-b border-gray-200">
                  <th scope="row" class="px-3 sm:px-6 py-2 sm:py-4 font-medium text-gray-900 whitespace-nowrap">
                    <%= drink.name %>
                  </th>
                  <td class="px-3 sm:px-6 py-2 sm:py-4">
                    <%= drink.quantity %>
                  </td>
                  <td class="px-3 sm:px-6 py-2 sm:py-4">
                    Alkohol
                  </td>
                  <td class="px-3 sm:px-6 py-2 sm:py-4">
                    <%= drink.price %> €
                  </td>
                  <td class="px-3 sm:px-6 py-2 sm:py-4">
                    <button phx-click="remove_from_order" phx-value-id={drink.id} class="text-red-600 hover:underline">Odstrani</button>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>

        <.add_to_order drinks={@drinks}/>

        <div class="flex sm:flex-row items-center justify-between p-4 sm:p-5 bg-white gap-4 sm:gap-0">
          <div class="text-base sm:text-3xl font-semibold">Skupen znesek: <%= @order.total_price %> €</div>
          <button id="capture" phx-hook="CameraHook" phx-click="confirm_order" class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm sm:text-lg px-4 sm:px-5 py-2 sm:py-2.5 text-center">
            Potrdi naročilo
          </button>
        </div>
      </div>

    """
  end

  attr :order, :map, required: true, doc: "order information"
  attr :drinks, :list, required: true, doc: "list of drinks"
  attr :kontakt, :map, required: true, doc: "list of drinks"
  def order_block_delivery(assigns) do
    ~H"""
      <div class="fixed inset-0 z-30 flex flex-col bg-white shadow-lg overflow-auto">
        <div class="flex justify-between items-center px-4 sm:px-5">
          <div>
            <h2 class="text-lg sm:text-3xl mt-6 sm:mt-10 font-bold">Preglej naročilo</h2>
            <p class="text-sm sm:text-xl text-gray-600">Kasnejših reklamacij ne upoštevamo</p>
          </div>
          <button type="button" phx-click="close_order_view" class="text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-base sm:text-lg w-8 h-8 sm:w-10 sm:h-10 flex justify-center items-center" data-modal-hide="default-modal">
            <svg class="w-5 h-5 sm:w-6 sm:h-6" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 14">
              <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"/>
            </svg>
            <span class="sr-only">Zapri</span>
          </button>
        </div>

        <div class="relative overflow-x-auto sm:rounded-lg mt-6 sm:mt-10 flex-1 min-h-0">
          <table class="w-full text-xs sm:text-sm text-left text-gray-500">
            <thead class="text-xs text-gray-700 uppercase bg-gray-50">
              <tr>
                <th scope="col" class="px-3 sm:px-6 py-2 sm:py-3">Hrana</th>
                <th scope="col" class="px-3 sm:px-6 py-2 sm:py-3">Količina</th>
                <th scope="col" class="px-3 sm:px-6 py-2 sm:py-3">Sestavine</th>
                <th scope="col" class="px-3 sm:px-6 py-2 sm:py-3">Cena</th>
                <th scope="col" class="px-3 sm:px-6 py-2 sm:py-3"></th>
              </tr>
            </thead>
            <tbody>
              <%= for {_id, food} <- @order.food do %>
                <tr class="odd:bg-white even:bg-gray-50 border-b border-gray-200">
                  <th scope="row" class="px-3 sm:px-6 py-2 sm:py-4 font-medium text-gray-900 whitespace-nowrap">
                    <%= food.name %>
                  </th>
                  <td class="px-3 sm:px-6 py-2 sm:py-4">
                    <%= food.quantity %>
                  </td>
                  <td class="px-3 sm:px-6 py-2 sm:py-4">
                    <%= Enum.join(food.ingredients, ", ") %>
                  </td>
                  <td class="px-3 sm:px-6 py-2 sm:py-4">
                    <%= food.price %> €
                  </td>
                  <td class="px-3 sm:px-6 py-2 sm:py-4">
                    <button phx-click="remove_from_order" phx-value-id={food.id} class="text-red-600 hover:underline">Odstrani</button>
                  </td>
                </tr>
              <% end %>

              <%= for {_id, drink} <- @order.drinks do %>
                <tr class="odd:bg-white even:bg-gray-50 border-b border-gray-200">
                  <th scope="row" class="px-3 sm:px-6 py-2 sm:py-4 font-medium text-gray-900 whitespace-nowrap">
                    <%= drink.name %>
                  </th>
                  <td class="px-3 sm:px-6 py-2 sm:py-4">
                    <%= drink.quantity %>
                  </td>
                  <td class="px-3 sm:px-6 py-2 sm:py-4">
                    Alkohol
                  </td>
                  <td class="px-3 sm:px-6 py-2 sm:py-4">
                    <%= drink.price %> €
                  </td>
                  <td class="px-3 sm:px-6 py-2 sm:py-4">
                    <button phx-click="remove_from_order" phx-value-id={drink.id} class="text-red-600 hover:underline">Odstrani</button>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>

        <div class="px-4 sm:px-5">
          <button phx-click="show_kontakt" class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm sm:text-lg px-4 sm:px-5 py-2 sm:py-2.5 text-center">
            Vnesi podatke za dostavo
          </button>
        </div>

        <.add_to_order drinks={@drinks}/>

        <div class="flex sm:flex-row items-center justify-between p-4 sm:p-5 bg-white gap-4 sm:gap-0">
          <div class="text-base sm:text-3xl font-semibold">Skupen znesek: <%= @order.total_price %> €</div>
          <%= if map_size(@kontakt) == 0 do %>
            <button id="capture" phx-click="confirm_order" disabled class="text-white bg-gray-500 font-medium rounded-lg text-sm sm:text-lg px-4 sm:px-5 py-2 sm:py-2.5 text-center">
              Oddaj naročilo!
            </button>
          <% else %>
            <button id="capture" phx-click="confirm_order" class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm sm:text-lg px-4 sm:px-5 py-2 sm:py-2.5 text-center">
              Oddaj naročilo!
            </button>
          <% end %>
        </div>
      </div>

    """
  end

  def welcome_block(assigns) do
    flags = get_random_flags()
    translations = get_translations()
    ~H"""
      <section class="fixed inset-0 z-30 bg-white">
        <div class=" flex flex-col h-full justify-between py-5 sm:py-10 px-2 sm:px-4 mx-auto max-w-screen-3xl text-center lg:py-16">
            <h1 class="mb-2 sm:mb-4 text-3xl sm:text-4xl font-extrabold tracking-tight leading-none text-gray-900 md:text-5xl lg:text-6xl">HRANA DISKONT</h1>
            <p class="mb-4 sm:mb-20 text-base sm:text-lg font-normal text-gray-500 lg:text-xl sm:px-16 lg:px-48">Najej se, ne samu pit.<br>Prekomerno uživanje alkohola lahko škodije zdravju. Lahko pa tudi ne.</p>
            <div class="flex flex-row gap-4 sm:flex-row sm:justify-center sm:space-y-0">
                <button phx-click="remove_welcome" class="p-10 text-lg sm:text-2xl font-medium text-center text-white rounded-lg bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300">

                    <img class="w-2/3 mx-auto" src="/images/drunk.png" alt="arrow right" />
                    <p class="mt-5 sm:mt-10">Za tukej</p>
                </button>
                <button phx-click="remove_welcome" class="p-10 text-lg sm:text-2xl font-medium text-center text-white rounded-lg bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300">

                  <img class="w-2/3 mx-auto" src="/images/drink.png" alt="arrow right" />
                  <p class="mt-5 sm:mt-10">Za sabo</p>
                </button>
            </div>
            <p class="mt-5 sm:mt-8 text-sm sm:text-lg font-normal text-gray-400 lg:text-xl sm:px-16 lg:px-48"><i>* Nima veze kaj zbereš, ne nrdi razlike</i></p>

            <div class="flex flex-col gap-2 rounded-lg bg-gray-50 p-3 mt-5 sm:mt-10 overflow-scroll">
              <div class="flex items-center gap-2">
                <img src={"/images/slovenia.svg"} alt="Flag" class="w-11 h-7 object-cover" />
                <p class="text-lg font-semibold text-gray-700">Dobrodošli</p>
              </div>
              <div class="flex items-center gap-2">
                <img src={"/images/uk.svg"} alt="Flag" class="w-11 h-7 object-cover" />
                <p class="text-lg font-semibold text-gray-700">Wellcum</p>
              </div>
              <%= for flag <- flags do %>
                <div class="flex items-center gap-2">
                  <img src={flag} alt="Flag" class="w-11 h-7 object-cover" />
                  <p class="text-lg font-semibold text-gray-700"><%= Map.get(translations, Path.basename(flag, ".svg"), "Unknown") %></p>
                </div>
              <% end %>
            </div>

        </div>
      </section>
    """
  end

  def welcome_block_delivery(assigns) do
    flags = get_random_flags()
    translations = get_translations()
    ~H"""
      <section class="fixed inset-0 z-30 bg-white">
        <div class=" flex flex-col h-full justify-between py-5 sm:py-10 px-2 sm:px-4 mx-auto max-w-screen-3xl text-center lg:py-16">
            <h1 class="mt-2 sm:mb-4 text-3xl sm:text-4xl font-extrabold tracking-tight leading-none text-gray-900 md:text-5xl lg:text-6xl">DOSTAVA TOMBA</h1>
            <p class="mb-4 sm:mb-20 text-base sm:text-lg font-normal text-gray-500 lg:text-xl sm:px-16 lg:px-48">Naroči hrano in pijačo.<br>Mi pripravimo, tomba dostavi.</p>
            <div>
                <button phx-click="remove_welcome" class="p-10 text-lg sm:text-2xl font-medium text-center text-white rounded-lg bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300">
                    <img class="w-2/3 mx-auto" src="/images/drunk.png" alt="arrow right" />
                    <p class="mt-5 sm:mt-10 text-2xl">Vstopi</p>
                </button>
            </div>
            <div class="flex flex-col gap-2 rounded-lg bg-gray-50 p-3 mt-5 sm:mt-10 overflow-scroll">
              <div class="flex items-center gap-2">
                <img src={"/images/slovenia.svg"} alt="Flag" class="w-11 h-7 object-cover" />
                <p class="text-lg font-semibold text-gray-700">Dobrodošli</p>
              </div>
              <div class="flex items-center gap-2">
                <img src={"/images/uk.svg"} alt="Flag" class="w-11 h-7 object-cover" />
                <p class="text-lg font-semibold text-gray-700">Wellcum</p>
              </div>
              <%= for flag <- flags do %>
                <div class="flex items-center gap-2">
                  <img src={flag} alt="Flag" class="w-11 h-7 object-cover" />
                  <p class="text-lg font-semibold text-gray-700"><%= Map.get(translations, Path.basename(flag, ".svg"), "Unknown") %></p>
                </div>
              <% end %>
            </div>

        </div>
      </section>
    """
  end

  attr :drinks, :list, required: true, doc: "drink name"
  def add_to_order(assigns) do
    ~H"""
    <div class="bg-gray-50 p-3 sm:p-6 rounded-lg">
      <h2 class="text-base sm:text-3xl font-bold mb-3 sm:mb-4">Ostali so si privoščili tudi:</h2>
      <div class="flex gap-3 sm:gap-4 overflow-x-auto whitespace-nowrap scrollbar-hide">
        <%= for drink <- @drinks do %>
          <%= if drink.name != "Runda" do %>
            <div phx-click="show_modal_pijaca" phx-value-drink_id={drink.id} class="min-w-[160px] sm:min-w-[250px] p-4 sm:p-6 bg-white border border-gray-200 rounded-lg shadow-sm">
              <a href="#">
                <h5 class="mb-1 sm:mb-2 text-base sm:text-2xl font-bold tracking-tight text-gray-900">
                  <%= drink.name %>
                </h5>
              </a>
              <img class="h-24 sm:h-32 rounded-lg mx-auto" src={"/images/#{drink.slug}.png"} alt="product image"/>
              <div class="flex items-center justify-between mt-4 sm:mt-6">
                <a href="#" class="inline-flex items-center px-2 py-1 sm:px-3 sm:py-2 text-sm sm:text-base font-medium text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300">
                  Ajde dej
                  <svg class="rtl:rotate-180 w-3 h-3 sm:w-3.5 sm:h-3.5 ms-2" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                    <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 5h12m0 0L9 1m4 4L9 9"/>
                  </svg>
                </a>
                <span class="text-base sm:text-lg font-bold text-gray-900"><%= drink.price %></span>
              </div>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>


    """
  end

  def loading_block(assigns) do
    ~H"""
      <div class="fixed inset-0 z-30 flex items-center justify-center bg-white">
        <div class="flex flex-col items-center space-y-4">
          <img class="w-full" src="/images/loading-1.gif" alt="loading" />
          <p class="text-3xl font-semibold text-gray-900">Dej počak mal ...</p>
        </div>
      </div>
    """
  end

  def cebula_modal(assigns) do
    ~H"""
      <div id="default-modal" tabindex="-1" aria-hidden="true"
        class="overflow-y-auto overflow-x-hidden fixed top-0 right-0 left-0 z-50 flex justify-center items-center w-full md:inset-0 h-[calc(100%-1rem)] max-h-full before:content-[''] before:fixed before:inset-0 before:bg-black before:opacity-50">
            <div class="relative p-4 w-full max-w-2xl max-h-full">
                <!-- Modal content -->
                <div class="relative bg-white rounded-lg shadow-sm">
                    <!-- Modal header -->
                    <div class="flex items-center justify-between p-4 md:p-5 border-b rounded-t border-gray-200">
                        <h3 class="text-2xl font-semibold text-gray-900">
                            A se boš lubčkou?
                        </h3>
                        <button type="button" phx-click="close_modal_cebula" class="text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm w-8 h-8 ms-auto inline-flex justify-center items-center" data-modal-hide="default-modal">
                            <svg class="w-3 h-3" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 14">
                                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"/>
                            </svg>
                            <span class="sr-only">Close modal</span>
                        </button>
                    </div>
                    <!-- Modal body -->
                    <div class="p-4 md:p-5 space-y-4">
                      <p class="text-lg leading-relaxed text-gray-500">
                        Čebula (Allium cepa) je priljubljena vrtnina, ki jo uporabljamo v kulinariki po vsem svetu. Ima značilen oster vonj in okus, ki med kuhanjem postane slajši. Bogata je z vitamini, minerali in antioksidanti ter ima številne koristne učinke na zdravje, saj krepi imunski sistem, deluje protivnetno in podpira zdravje srca. Uporabljamo jo surovo v solatah, kuhano v juhah in omakah ali kot začimbo v različnih jedeh. Poleg tega je nepogrešljiva sestavina mnogih tradicionalnih receptov.
                      </p>
                      <img src="/images/gifs/cebula.gif" alt="cebula" class="w-full mx-auto" />
                    </div>
                    <!-- Modal footer -->
                    <div class="flex items-center p-4 md:p-5 border-t border-gray-200 rounded-b">
                        <button phx-click="close_modal_cebula" type="button" class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-2xl px-5 py-2.5 text-center">NE</button>
                    </div>
                </div>
            </div>
        </div>
    """
  end

  attr :drink, :string, required: true, doc: "selected drink"
  def pijaca_modal(assigns) do
    ~H"""
      <div id="default-modal" tabindex="-1" aria-hidden="true"
        class="overflow-y-auto overflow-x-hidden fixed top-0 right-0 left-0 z-50 flex justify-center items-center w-full md:inset-0 h-[calc(100%-1rem)] max-h-full before:content-[''] before:fixed before:inset-0 before:bg-black before:opacity-50">
            <div class="relative p-4 w-full max-w-2xl max-h-full">
                <!-- Modal content -->
                <div class="relative bg-white rounded-lg shadow-sm">
                    <!-- Modal header -->
                    <div class="flex items-center justify-between p-4 md:p-5 border-b rounded-t border-gray-200">
                        <h3 class="text-3xl font-bold text-red-900">
                          ! POZOR POZOR POZOR POZOR !
                        </h3>
                        <button type="button" phx-click="close_modal_pijaca" class="text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm w-8 h-8 ms-auto inline-flex justify-center items-center" data-modal-hide="default-modal">
                            <svg class="w-6 h-6" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 14">
                                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"/>
                            </svg>
                            <span class="sr-only">Close modal</span>
                        </button>
                    </div>
                    <!-- Modal body -->
                    <div class="p-4 md:p-5 space-y-4">
                        <p class="text-lg leading-relaxed text-gray-500">
                          Redno uživanje alkohola povečuje tveganje za bolezni jeter, srčno-žilne težave ter motnje v delovanju živčnega sistema, kar vodi v težave z razpoloženjem in kakovostjo spanja. Poleg tega pivo vsebuje veliko kalorij, ki prispevajo k povečanju telesne mase, še posebej okoli trebuha, kar lahko vodi v dolgoročne zdravstvene težave. Namesto tega je bolje izbrati zdrave načine sprostitve, ki bodo imeli pozitivne učinke na telo in um.
                        </p>
                        <img src="/images/gifs/pivo.gif" alt="pivo" class="w-full mx-auto" />
                    </div>
                    <!-- Modal footer -->
                    <div class="flex justify-between items-center p-4 md:p-5 border-t border-gray-200 rounded-b">
                        <a phx-click="add_to_order" phx-value-id_food={1006} phx-value-quantity-input={1} phx-value-ingredients={1} class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-xl text-2xl px-10 py-2.5 text-center">Ne pij sam, dej za rundo!</a>
                        <a phx-click="add_to_order" phx-value-id_food={@drink.id} phx-value-quantity-input={1} phx-value-ingredients={1} class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center">ne dam za rundo</a>
                    </div>
                </div>
            </div>
        </div>
    """
  end

  attr :kontakt, :map, required: true, doc: "kontakt"
  def kontakt_block(assigns) do
    ~H"""
      <div class="fixed inset-0 z-40 p-3 flex flex-col items-center justify-center bg-white">
        <h2 class="text-2xl font-semibold mb-4">Vnesi podatke za dostavo</h2>
        <form phx-submit="save_kontakt_data" class="space-y-4 w-full">
          <div>
            <label class="block text-sm font-medium text-gray-700">Ime</label>
            <input type="text" name="name" required class="w-full p-2 border border-gray-300 rounded-md">
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Priimek</label>
            <input type="text" name="surename" required class="w-full p-2 border border-gray-300 rounded-md">
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Telefonska številka</label>
            <input type="text" name="phone" required class="w-full p-2 border border-gray-300 rounded-md">
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Hišna številka</label>
            <textarea name="address" required class="w-full p-2 border border-gray-300 rounded-md"></textarea>
          </div>

          <div>
            <button type="submit" class="w-full bg-blue-500 text-white py-2 rounded-md hover:bg-blue-600">Shrani</button>
          </div>
        </form>
      </div>
    """
  end

  defp get_random_flags do
    "./priv/static/images/flags"
    |> File.ls!()
    |> Enum.shuffle()
    |> Enum.take(10)
    |> Enum.map(&"/images/flags/#{&1}")
  end

  defp get_translations do
    %{
      "france" => "Tire-moi la bite",
      "germany" => "Zieh mir am Schwanz",
      "italy" => "Tirami il cazzo",
      "spain" => "Tírame de la polla",
      "albania" => "tërhiq tubin tim",
      "russia" => "Тяни мой член",
      "china" => "拉我的鸡巴"
    }
  end

end
