defmodule KioskTest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KioskTest.Supervisor]

    children =
      [
        # Children for all targets
        # Starts a worker by calling: KioskTest.Worker.start_link(arg)
        # {KioskTest.Worker, arg},
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: KioskTest.Worker.start_link(arg)
      # {KioskTest.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: KioskTest.Worker.start_link(arg)
      # {KioskTest.Worker, arg},
    ]
  end

  def target() do
    Application.get_env(:kiosk_test, :target)
  end

  def platform_init_events(udev_init_delay_ms \\ 5_000) do
    # Initialize eudev
    :os.cmd('udevd -d');
    :os.cmd('udevadm trigger --type=subsystems --action=add');
    :os.cmd('udevadm trigger --type=devices --action=add');
    :os.cmd('udevadm settle --timeout=30');
    Process.sleep(udev_init_delay_ms)
  end

  def init_kiosk(udev_init \\ true) do
    if udev_init, do: platform_init_events()

    # Need to set the cache dir to not reside in /tmp/...
    System.put_env("XDG_RUNTIME_DIR", "/root/cache/")
    # Not sure these are needed now... but it's working and it's late ;)
    # System.put_env("QTWEBENGINE_CHROMIUM_FLAGS", " --no-sandbox --remote-debugging-port=1234  ")
    # System.put_env("QTWEBENGINE_CHROMIUM_FLAGS", " --no-sandbox ")

    # webengine (aka chromium) uses /dev/shm for shared memory.
    # On Nerves it maps to devtmpfs which is waay too small.
    # Haven't found an option to set the shm file, so we get this hack:
    File.rm_rf "/root/shm"
    File.mkdir_p! "/root/shm"
    File.rm_rf "/dev/shm"
    File.ln_s! "/root/shm", "/dev/shm"

    Process.sleep(100)
    Logger.info("starting web kiosk")

    {:ok, kiosk} = WebengineKiosk.start_link(
      fullscreen: true,
      data_dir: "/root/browser/",
      homepage: "blank",
      background_color: "black",
      sounds: false,
      run_as_root: true)

    kiosk
  end
end
