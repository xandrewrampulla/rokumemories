"""Build separate normal-app and standalone-screensaver Roku packages."""

import argparse
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile


PLUGIN_DIR = Path(__file__).resolve().parent
SOURCE_DIR = PLUGIN_DIR / "src" / "roku"


def build_package(mode="app", output=None):
    if mode not in ("app", "screensaver"):
        raise ValueError("Expected app or screensaver")

    excluded_entry = (
        "source/main.brs" if mode == "screensaver" else "source/ScreensaverEntry.brs"
    )
    manifest = []
    for line in (SOURCE_DIR / "manifest").read_text().splitlines():
        key = line.partition("=")[0].strip()
        if mode == "screensaver" and key == "title":
            continue
        if mode == "app" and key.startswith("screensaver_"):
            continue
        manifest.append(line)

    filename = "roku-screensaver.zip" if mode == "screensaver" else "roku.zip"
    output = Path(output) if output is not None else PLUGIN_DIR / "build" / filename
    output.parent.mkdir(parents=True, exist_ok=True)
    # Recreate the ZIP so files excluded from this mode cannot survive old builds.
    with ZipFile(output, "w", compression=ZIP_DEFLATED) as archive:
        archive.writestr("manifest", "\n".join(manifest) + "\n")
        for path in sorted(SOURCE_DIR.rglob("*")):
            if not path.is_file() or path.name == ".DS_Store":
                continue
            relative = path.relative_to(SOURCE_DIR).as_posix()
            if relative in ("manifest", excluded_entry):
                continue
            archive.write(path, relative)
    return output


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", nargs="?", choices=("app", "screensaver"), default="app")
    args = parser.parse_args()
    print(f"Built {args.mode}: {build_package(args.mode)}")


if __name__ == "__main__":
    main()
