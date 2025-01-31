defmodule FoodOrdering.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FoodOrderingWeb.Telemetry,
      FoodOrdering.Repo,
      {DNSCluster, query: Application.get_env(:food_ordering, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FoodOrdering.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: FoodOrdering.Finch},
      # Start a worker by calling: FoodOrdering.Worker.start_link(arg)
      # {FoodOrdering.Worker, arg},
      # Start to serve requests, typically the last entry
      FoodOrderingWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FoodOrdering.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FoodOrderingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
