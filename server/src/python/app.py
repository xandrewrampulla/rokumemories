#!/usr/bin/env python3

import asyncio
import random
import zipfile
import tempfile
import shutil
from pathlib import Path

import aiofiles
from aiohttp import web

PICTURE_DIR = Path("/pics")
ALLOWED_EXTENSIONS = {
    ".jpg",
    ".jpeg",
    ".png",
    ".gif",
    ".bmp",
    ".webp",
    ".tif",
    ".tiff",
}


class PictureLibrary:

    def __init__(self, picture_dir: Path):
        self.picture_dir = picture_dir
        self.lock = asyncio.Lock()
        self.shuffle = []
        self.index = 0

    async def load(self):
        async with self.lock:
            await self._reload()


    async def _reload(self):
        self.picture_dir.mkdir(parents=True, exist_ok=True)

        self.shuffle = sorted([
            str(f.relative_to(self.picture_dir))
            for f in self.picture_dir.rglob("*")
            if (f.is_file()
                and f.suffix.lower() in ALLOWED_EXTENSIONS
                and not f.name.startswith("._"))
        ])

        random.shuffle(self.shuffle)

        if not self.shuffle:
            self.index = 0
        else:
            self.index %= len(self.shuffle)

    async def next(self):
        async with self.lock:
            if not self.shuffle:
                return None

            filename = self.shuffle[self.index]
            self.index = (self.index + 1) % len(self.shuffle)
            return filename

    async def previous(self):
        async with self.lock:
            if not self.shuffle:
                return None

            self.index = (self.index - 1) % len(self.shuffle)
            return self.shuffle[self.index]

    async def delete(self, filename):
        async with self.lock:

            path = self.picture_dir / filename

            if not path.exists():
                return False

            path.unlink()

            await self._reload()
            return True

    async def add_image(self, src: Path):
        dst = self.picture_dir / src.name
        shutil.move(src, dst)

    async def rescan(self):
        async with self.lock:
            await self._reload()


library = PictureLibrary(PICTURE_DIR)

###########################################################################
# Helper for loading rotating, scaling the picture
###########################################################################

from io import BytesIO

from PIL import Image
from PIL import ImageOps

DISPLAY_WIDTH = 1920
DISPLAY_HEIGHT = 1080


async def send_picture(filename):

    path = PICTURE_DIR / filename

    if not path.exists():
        raise web.HTTPNotFound()

    #
    # Load image
    #
    image = Image.open(path)

    #
    # Rotate according to EXIF
    #
    image = ImageOps.exif_transpose(image)

    #
    # Convert to RGB
    #
    if image.mode != "RGB":
        image = image.convert("RGB")

    #
    # Scale while preserving aspect ratio.
    #
    image.thumbnail(
        (DISPLAY_WIDTH, DISPLAY_HEIGHT),
        Image.Resampling.LANCZOS
    )

    #
    # Create black background
    #
    canvas = Image.new(
        "RGB",
        (DISPLAY_WIDTH, DISPLAY_HEIGHT),
        (0, 0, 0)
    )

    #
    # Center image
    #
    x = (DISPLAY_WIDTH - image.width) // 2
    y = (DISPLAY_HEIGHT - image.height) // 2

    canvas.paste(image, (x, y))

    #
    # Encode to JPEG
    #
    output = BytesIO()

    canvas.save(
        output,
        format="JPEG",
        quality=90
    )

    return web.Response(
        body=output.getvalue(),
        content_type="image/jpeg"
    )


###########################################################################
# GET /pictures/<filename>
###########################################################################

async def get_picture(request):
    filename = request.match_info["filename"]
    return await send_picture(filename)

###########################################################################
# GET /pictures/next
###########################################################################

async def next_picture(request):
    filename = await library.next()
    if filename is None:
        raise web.HTTPNotFound()
    return await send_picture(filename)


###########################################################################
# GET /pictures/back
###########################################################################

async def previous_picture(request):
    filename = await library.previous()
    if filename is None:
        raise web.HTTPNotFound()
    return await send_picture(filename)


###########################################################################
# PUT /pictures/
###########################################################################

async def upload(request):

    reader = await request.multipart()

    field = await reader.next()

    if field is None:
        raise web.HTTPBadRequest(text="No uploaded file")

    filename = Path(field.filename).name

    with tempfile.TemporaryDirectory() as td:

        temp = Path(td) / filename

        async with aiofiles.open(temp, "wb") as f:
            while True:
                chunk = await field.read_chunk()

                if not chunk:
                    break

                await f.write(chunk)

        if temp.suffix.lower() == ".zip":

            with zipfile.ZipFile(temp) as z:

                for member in z.infolist():

                    if member.is_dir():
                        continue

                    suffix = Path(member.filename).suffix.lower()

                    if suffix not in ALLOWED_EXTENSIONS:
                        continue

                    dest = PICTURE_DIR / Path(member.filename).name

                    with z.open(member) as src, open(dest, "wb") as dst:
                        shutil.copyfileobj(src, dst)

        else:

            if temp.suffix.lower() not in ALLOWED_EXTENSIONS:
                raise web.HTTPBadRequest(text="Unsupported image type")

            shutil.move(temp, PICTURE_DIR / filename)

    await library.rescan()

    return web.json_response({
        "count": len(library.shuffle)
    })


###########################################################################
# DELETE /pictures/<filename>
###########################################################################

async def delete_picture(request):

    filename = request.match_info["filename"]

    deleted = await library.delete(filename)

    if not deleted:
        raise web.HTTPNotFound()

    return web.Response(status=204)


###########################################################################

async def root(request):
    return web.HTTPFound("/static/index.html")

async def startup(app):
    await library.load()


app = web.Application()

app.on_startup.append(startup)

app.router.add_get("/", root)

app.router.add_static("/static/", Path(__file__).parent / "static")

app.router.add_get("/pictures/next", next_picture)
app.router.add_get("/pictures/back", previous_picture)
app.router.add_get("/pictures/{filename}", get_picture)

app.router.add_put("/pictures/", upload)

app.router.add_delete("/pictures/{filename}", delete_picture)

web.run_app(app, host="0.0.0.0", port=8080)


