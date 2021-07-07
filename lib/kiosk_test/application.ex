defmodule KioskTest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @kiosk_options [
      fullscreen: true,
      virtualkeyboard: true,
      context_menu: false,
      sounds: false,

      data_dir: "/root/browser/",
      homepage: "about:blank",

      run_as_root: true,
      platform_udev: true,
      platform_shared_memory: true,
      platform_cache_dir: true,
    ]

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    opts = [strategy: :one_for_one, name: KioskTest.Supervisor]

    children =
      [
        {WebengineKiosk, {@kiosk_options, name: Display}},
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # {KioskTest.Worker, arg},
    ]
  end

  def children(_target) do
    [
    ]
  end

  def target() do
    Application.get_env(:kiosk_test, :target)
  end

end
