# Roku Memories builds

Roku classifies a package with `title` as a regular app. A standalone screensaver
uses `screensaver_title` instead and must not provide `Main()` or
`RunUserInterface()`. The build script selects the appropriate manifest and entry
points while retaining the shared slideshow and settings implementation.

## Normal app

From this directory:

```sh
sh makeroku.sh
bash deployroku.sh
```

This builds and installs `build/roku.zip`. The app launches from the Home screen,
supports left/right navigation, and opens settings with Options (`*`).

## Screensaver

From this directory:

```sh
sh makeroku.sh screensaver
bash deployroku.sh build/roku-screensaver.zip
```

This builds and installs `build/roku-screensaver.zip`. Open
**Settings > Theme > Screensavers** to select Roku Memories (the sideloaded entry
may have a developer label), preview it, and configure its URL and delay through
the screensaver settings menu. Any remote input dismisses the screensaver.

Only one package can be sideloaded at a time. Installing the screensaver replaces
the sideloaded normal app; the default build/deploy commands restore the normal
app. Both modes remain available as build targets, rather than as one combined
installed package. The build scripts require Python 3.

References: [Roku screensaver rules](https://developer.roku.com/dev/docs/screensavers),
[manifest classification](https://forum.developer.roku.com/t/static-analysis-blocks-a-dedicated-screensaver-false-positive-in-channel-screensaver-req-4-5/11503/4),
[sideloading limit](https://developer.roku.com/dev/docs/developer-setup).
