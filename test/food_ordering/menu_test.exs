defmodule FoodOrdering.MenuTest do
  use FoodOrdering.DataCase

  alias FoodOrdering.Menu

  describe "food_menus" do
    alias FoodOrdering.Menu.Food

    import FoodOrdering.MenuFixtures

    @invalid_attrs %{}

    test "list_food_menus/0 returns all food_menus" do
      food = food_fixture()
      assert Menu.list_food_menus() == [food]
    end

    test "get_food!/1 returns the food with given id" do
      food = food_fixture()
      assert Menu.get_food!(food.id) == food
    end

    test "create_food/1 with valid data creates a food" do
      valid_attrs = %{}

      assert {:ok, %Food{} = food} = Menu.create_food(valid_attrs)
    end

    test "create_food/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Menu.create_food(@invalid_attrs)
    end

    test "update_food/2 with valid data updates the food" do
      food = food_fixture()
      update_attrs = %{}

      assert {:ok, %Food{} = food} = Menu.update_food(food, update_attrs)
    end

    test "update_food/2 with invalid data returns error changeset" do
      food = food_fixture()
      assert {:error, %Ecto.Changeset{}} = Menu.update_food(food, @invalid_attrs)
      assert food == Menu.get_food!(food.id)
    end

    test "delete_food/1 deletes the food" do
      food = food_fixture()
      assert {:ok, %Food{}} = Menu.delete_food(food)
      assert_raise Ecto.NoResultsError, fn -> Menu.get_food!(food.id) end
    end

    test "change_food/1 returns a food changeset" do
      food = food_fixture()
      assert %Ecto.Changeset{} = Menu.change_food(food)
    end
  end
end
