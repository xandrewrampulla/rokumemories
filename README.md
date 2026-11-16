# Roku Memories

A Roku photo slideshow with two build targets: a normal Home-screen app and a
standalone screensaver. Both use the same slideshow and settings code and load
photos from a Python server on another computer.

## Prerequisites

- Enable [developer mode](https://developer.roku.com/dev/docs/developer-setup)
  on the Roku and set its developer password.
- Connect the computer and Roku to a network where they can reach each other.
- Install Python 3 and `curl` on the build/deployment computer. The build script
  uses only Python's standard library; the BrightScript compiler is optional.
- Set `ROKU_IP` in `plugin/deployroku.sh` to the Roku's address. Also update the
  address in the debug scripts under `plugin/src/` if you use them.
- Start the photo server and ensure it is reachable from the Roku.

The deploy script reads the developer password from `plugin/.rokupassword` when
that file exists and is nonempty; otherwise, it prompts without echoing the
password. Keep that file private and do not commit it.

## Build and deploy the normal app

From the repository root:

```sh
cd plugin
sh makeroku.sh
bash deployroku.sh
```

This builds `plugin/build/roku.zip` and uploads it to the Roku. Launch **Roku
Memories** from the Home screen. Left/right advances to the next/previous photo,
Options (`*`) opens settings, and Back exits the slideshow.

## Build and deploy the screensaver

From the repository root:

```sh
cd plugin
sh makeroku.sh screensaver
bash deployroku.sh build/roku-screensaver.zip
```

This builds and uploads `plugin/build/roku-screensaver.zip`. It is a standalone
screensaver, so deployment may only produce compilation messages without
changing the TV display or immediately starting the slideshow.

On the Roku:

1. Open **Settings > Theme > Screensavers**.
2. Find the developer entry. On the development Roku it appears as **(dev)**,
   rather than **Roku Memories**.
3. Select it and choose **Set as screensaver** if it is not already selected.
4. Open **Change screensaver settings** (wording may vary by Roku OS version)
   to configure the photo server and delay.
5. Choose **Preview**, if available, to test it immediately. Otherwise, set a
   short **Screensaver wait time** in the Theme menu, return Home, and leave the
   remote untouched until that interval expires.

Any remote input dismisses the running screensaver.

Roku allows [only one sideloaded package at a time](https://developer.roku.com/dev/docs/developer-setup).
Installing the screensaver replaces the sideloaded normal app. Run the normal
app build/deploy commands to switch back. Both modes remain available in the
source, but cannot be sideloaded simultaneously.

The build script selects the appropriate manifest and entry points for each
mode. A standalone screensaver uses `screensaver_title` instead of `title` and
does not include `Main()`. See [plugin build details](plugin/README.md).

## Configure the photo server

The normal app opens settings automatically when no URL is saved. For a deployed
screensaver, use its settings menu described above.

1. Select **Edit server URL**, enter the server's base URL, and choose **Apply**.
   Use its LAN address, such as `http://192.168.1.100:8080`, not `localhost`.
   Include any API path prefix required by the server.
2. Optionally select **Edit delay** and enter a positive whole number of seconds.
   The default is **15 seconds**.
3. Select **Save** to persist both settings on the Roku. Apply only accepts an
   individual field; Cancel or Back from the settings page discards pending edits.

The plugin requests raw image bytes from `$baseUrl/next` and `$baseUrl/prev`.
Base URLs may include a path prefix but cannot include a query or fragment;
trailing slashes are removed. The photo server must provide these endpoints.

Photos are centered without stretching, with black bars where needed. The last
displayed photo stays visible while its replacement loads or if loading fails.

## Debugging on the Roku

From the `plugin` directory, connect before reproducing a problem:

```sh
# Normal app console (port 8085)
sh src/debug_app.sh

# Screensaver console (port 8087; use a separate terminal)
sh src/debug_screensaver.sh
```

These scripts require `telnet`. Compilation messages in the normal app console
do not prove that the screensaver has started. Watch the screensaver console
while selecting Preview or waiting for idle activation.

## Local validation

From the repository root, with `bsc` and the off-device `brs` interpreter
installed:

```sh
bsc --project plugin/bsconfig.json
python3 plugin/tests/run.py
python3 -m unittest discover -s plugin/tests -p 'test_*.py'
```

The Python package tests need only the standard library. See
[test details](plugin/tests/README.md). Device testing is still required for the
Roku settings UI, registry persistence, idle activation, remote dismissal, and
photo loading over your network.
