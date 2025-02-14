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
    <div class="grid grid-cols-3 gap-4 p-4">
      <%= for image <- @images do %>
        <div class="border rounded-lg p-2">
          <img src={"images/dashboard/#{image}"} alt={image} class="w-full h-auto rounded-lg shadow" />
          <p class="mt-2 text-sm text-center"><%= image %></p>
        </div>
      <% end %>
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
