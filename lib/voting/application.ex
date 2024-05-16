defmodule Voting.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      VotingWeb.Telemetry,
      Voting.Repo,
      {DNSCluster, query: Application.get_env(:voting, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Voting.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Voting.Finch},
      # Start a worker by calling: Voting.Worker.start_link(arg)
      # {Voting.Worker, arg},
      # Start to serve requests, typically the last entry
      VotingWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Voting.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VotingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
