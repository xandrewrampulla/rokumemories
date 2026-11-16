"""Verify the manifest and entry-point contracts for both Roku package types."""

import importlib.util
from pathlib import Path
import re
import tempfile
import unittest
from zipfile import ZipFile


builder_path = Path(__file__).resolve().parents[1] / "package_roku.py"
spec = importlib.util.spec_from_file_location("package_roku", builder_path)
builder = importlib.util.module_from_spec(spec)
spec.loader.exec_module(builder)


class PackageTests(unittest.TestCase):
    def test_manifests_and_entry_points(self):
        with tempfile.TemporaryDirectory() as directory:
            for mode in ("app", "screensaver"):
                with self.subTest(mode=mode):
                    output = builder.build_package(mode, Path(directory) / f"{mode}.zip")
                    with ZipFile(output) as archive:
                        self.assertIsNone(archive.testzip())
                        manifest = dict(
                            line.split("=", 1)
                            for line in archive.read("manifest").decode().splitlines()
                            if "=" in line and not line.startswith("#")
                        )
                        source = "\n".join(
                            archive.read(name).decode()
                            for name in archive.namelist()
                            if name.startswith("source/") and name.endswith(".brs")
                        )
                        entries = set(re.findall(r"(?im)^sub\s+(\w+)\(", source))
                        self.assertIn("runScene", entries)
                        self.assertIn("components/MainScene.xml", archive.namelist())
                        self.assertIn("components/ScreensaverScene.xml", archive.namelist())
                        if mode == "app":
                            self.assertEqual(manifest["title"], "Roku Memories")
                            self.assertNotIn("screensaver_title", manifest)
                            self.assertIn("Main", entries)
                            self.assertNotIn("RunScreenSaver", entries)
                        else:
                            self.assertEqual(manifest["screensaver_title"], "Roku Memories")
                            self.assertNotIn("title", manifest)
                            self.assertNotIn("Main", entries)
                            self.assertIn("RunScreenSaver", entries)
                            self.assertIn("RunScreenSaverSettings", entries)

    def test_rebuild_does_not_retain_stale_files(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "roku.zip"
            builder.build_package("app", output)
            with ZipFile(output, "a") as archive:
                archive.writestr("obsolete.brs", "stale file")
            builder.build_package("screensaver", output)
            with ZipFile(output) as archive:
                self.assertNotIn("obsolete.brs", archive.namelist())
                self.assertNotIn("source/main.brs", archive.namelist())


if __name__ == "__main__":
    unittest.main()
