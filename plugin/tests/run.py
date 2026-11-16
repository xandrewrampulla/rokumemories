"""Run off-device BrightScript behavior checks with `brs` available on PATH."""

from pathlib import Path
import subprocess
import sys


root = Path(__file__).resolve().parents[2]
scripts = [
    "plugin/src/roku/source/Configuration.brs",
    "plugin/src/roku/components/Slideshow.brs",
    "plugin/src/roku/components/MainScene.brs",
    "plugin/tests/behavior.brs",
]
result = subprocess.run(
    ["brs", "--root", "plugin/src/roku", *scripts],
    cwd=root,
    capture_output=True,
    text=True,
)
sys.stdout.write(result.stdout)
sys.stderr.write(result.stderr)
# The interpreter can return zero even after a BrightScript runtime error.
passed = "PASS: slideshow timing, navigation, failures, and settings behavior"
sys.exit(0 if result.returncode == 0 and passed in result.stdout and "FAIL" not in result.stdout and not result.stderr else 1)
