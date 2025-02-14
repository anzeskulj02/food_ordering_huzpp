# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     FoodOrdering.Repo.insert!(%FoodOrdering.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias FoodOrdering.Repo
alias FoodOrdering.Foods.{Food, Ingredient, FoodIngredient, Order, OrderItem}
alias FoodOrdering.Drinks.Drinks

drinks = [
  %{name: "Pivo", price: 2, slug: "pivo"},
  %{name: "Spricer bel", price: 2, slug: "spricer-rdec"},
  %{name: "Spricer rdeč", price: 2, slug: "spricer-bel"},
  %{name: "Sok", price: 2, slug: "sok"},
  %{name: "Wisky - Cola", price: 2.5, slug: "wiskycola"}
]

Enum.each(drinks, fn drink_attrs ->
  %Drinks{}
  |> Drinks.changeset(drink_attrs)
  |> Repo.insert!()
end)

"""
foods = Repo.all(Food)

orders =
  for i <- 1..5 do
    %Order{
      order_number: 1000 + i,
      total_price: Enum.random(10..50) |> Decimal.new(),
      status: "pending"
    }
    |> Repo.insert!()
  end

# Create sample order items
for order <- orders do
  food = Enum.random(foods)
  customizations = %{"extra_cheese" => true, "spicy" => false}

  %OrderItem{
    order_id: order.id,
    food_id: food.id,
    customizations: customizations
  }
  |> Repo.insert!()
end


# Ingredients
lettuce = Repo.insert!(%Ingredient{name: "Lettuce", additional_price: 0.0, slug: "lettuce"})
tomato = Repo.insert!(%Ingredient{name: "Tomato", additional_price: 0.0, slug: "tomato"})
cheese = Repo.insert!(%Ingredient{name: "Cheese", additional_price: 0.5, slug: "cheese"})
bacon = Repo.insert!(%Ingredient{name: "Bacon", additional_price: 1.0, slug: "bacon"})
garlic = Repo.insert!(%Ingredient{name: "Garlic", additional_price: 0.3, slug: "garlic"})

# Foods
burger = Repo.insert!(%Food{
  name: "Jufka",
  price: 5.0,
  description: "A classic beef burger with fresh ingredients.",
  calories: 500.0,
  slug: "jufka"
})

pizza = Repo.insert!(%Food{
  name: "Pomfri",
  price: 8.0,
  description: "Cheesy pizza with customizable toppings.",
  calories: 800.0,
  slug: "pomfri"
})

salad = Repo.insert!(%Food{
  name: "Roštilj mix",
  price: 4.0,
  description: "A fresh and healthy salad.",
  calories: 300.0,
  slug: "rostilj-mix"
})

# Food-Ingredient Relationships
Repo.insert!(%FoodIngredient{food_id: burger.id, ingredient_id: lettuce.id})
Repo.insert!(%FoodIngredient{food_id: burger.id, ingredient_id: tomato.id})
Repo.insert!(%FoodIngredient{food_id: burger.id, ingredient_id: cheese.id})
Repo.insert!(%FoodIngredient{food_id: burger.id, ingredient_id: bacon.id})

Repo.insert!(%FoodIngredient{food_id: pizza.id, ingredient_id: cheese.id})
Repo.insert!(%FoodIngredient{food_id: pizza.id, ingredient_id: garlic.id})
Repo.insert!(%FoodIngredient{food_id: pizza.id, ingredient_id: bacon.id})

Repo.insert!(%FoodIngredient{food_id: salad.id, ingredient_id: lettuce.id})
Repo.insert!(%FoodIngredient{food_id: salad.id, ingredient_id: tomato.id})
Repo.insert!(%FoodIngredient{food_id: salad.id, ingredient_id: garlic.id})
"""
