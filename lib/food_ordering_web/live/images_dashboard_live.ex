defmodule FoodOrderingWeb.ImagesDashboardLive do
  use FoodOrderingWeb, :live_view

  alias FoodOrderingWeb.CustomComponents

  @uploads_dir "./priv/static/images/dashboard"

  def mount(_params, _session, socket) do
    # List all images in the uploads directory
    images = list_uploaded_images()

    {:ok, assign(socket, images: images)}
  end

  def render(assigns) do
    ~H"""
    <div class="relative h-screen w-screen overflow-hidden">
      <div class="absolute top-0 left-0 flex items-center h-full w-[200%] animate-slide">
        <%= for _ <- 1..2 do %> <!-- Duplicate images for seamless loop -->
          <%= for image <- @images do %>
            <div class="h-full flex-none">
              <img src={"images/dashboard/#{image}"} alt={image} class="ml-5 w-auto object-cover rounded-lg shadow" />
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  defp list_uploaded_images do
    uploads_dir = Path.expand(@uploads_dir)

    case File.ls(uploads_dir) do
      {:ok, files} ->
        # Filter only image files (e.g., .png, .jpg)
        Enum.filter(files, fn file ->
          file =~ ~r/\.(png|jpg|jpeg|gif)$/i
        end)

      {:error, _reason} ->
        []
    end
  end

end
