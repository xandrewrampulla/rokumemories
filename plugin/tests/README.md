# Roku plugin checks

From the repository root, with `bsc` and `brs` installed:

```sh
bsc --project plugin/bsconfig.json
python3 plugin/tests/run.py
python3 -m unittest discover -s plugin/tests -p 'test_*.py'
```

The behavior checks run the production slideshow and settings functions with
fake SceneGraph fields and simulated image events. They cover display timing,
next/previous navigation, queued remote input, failed loads and timeouts,
settings validation, save/cancel, first launch, and the screensaver settings flow.
They do not make HTTP requests or write to the Roku registry.

The Python package checks verify that the normal app and standalone screensaver
contain the correct manifests and entry points, and that rebuilds discard stale
ZIP contents. See [build instructions](../README.md) for selecting a mode.

On a Roku, verify normal app startup and Options (`*`), first-launch settings,
editing and persistence across restarts, manual next/previous and Back, and idle
screensaver activation and dismissal. Confirm that a disconnected server leaves
the last displayed photo visible and that portrait/landscape photos fit without
stretching. The server must supply raw images at `$baseUrl/next` and
`$baseUrl/prev`; server changes are outside this work.

Settings pause automatic advancement. Back or Cancel discards pending edits;
Apply accepts an individual field, while Save persists both fields. A running
screensaver with no saved URL shows a configuration message, since remote input
dismisses it; open the app or Roku's screensaver settings to configure the URL.
