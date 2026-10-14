# Pixel Facades 100

## Folder guide

- `download/pixel_facades_100.zip`: ready-to-upload customer download.
- `store/preview.html`: store article and picture preview.
- `store/itch-fields.txt`: itch.io form values.
- `store/`: cover, banner, gallery pictures, description and publishing notes.
- `textures/`: finished facade PNGs.
- `facade_projects/` and `texturing_projects/`: editable native projects.
- `assets/`: wall tiles, window sprites and recipes.
- `previews/` and `catalog.html`: pack browsing and detail sheets.
- `LICENSE.txt`: free commercial-use terms.

The download ZIP excludes the local `store/` and `download/` folders.

100 opaque rectangular pixel-art facade textures. Every image is taller than
it is wide. Ten styles have ten variations each, with changes to floors,
window bays, entrances, commercial fronts, lighting in windows, shutters,
balconies, decoration and wear.

Open **catalog.html** to browse, filter styles and zoom with crisp pixels.
`previews/all_100.png` shows the whole pack; `previews/ten_styles.png` shows
one full-resolution example from each family.
`previews/window_interiors.png` shows the updated Boneglass windows at 4× zoom:
curtains and lamps, bookshelves, blinds with desks and plants, and warm rooms.
Interior layers sit behind mullions and small glass reflection streaks.

## Use in a game

- Import `textures/*.png`: 100 different native dimensions. Widths range from
  168–264 pixels and heights from 320–480 pixels. Every image is portrait.
- Use nearest-neighbour / point filtering. These are native pixel images,
  not blurred large renders or smooth images merely enlarged into blocks.
- Each texture uses at most 64 indexed colours and fills its rectangle.
- Map the entire image to a rectangular facade plane, preserving its aspect.
- The scale is 32 pixels per metre if a real-world scale is useful.
- The textures contain stylized relief shading. They are colour textures,
  not a full PBR material pack; they are not promised to tile seamlessly.

## Editable sources

- `facade_projects/`: 100 native projects for the Building Facade app.
- `texturing_projects/`: 100 native Building Texturing projects with anchored
  layer recipes and embedded window sprites.
- `assets/`: ten wall tiles, forty Boneglass windows and generator recipes.
- `manifest.json`: dimensions, style, seed, source paths and SHA-256 hashes.
- `validation.json`: automated pack checks.

Building Texturing needs its wall library loaded to replay materials. Use
`open_editor.py texturing 1` through the existing Python interpreter while
this pack is in this workspace. `open_editor.py facade 1` opens the matching
facade project. Replace 1 with an asset ID from 1 to 100.

## How this was made

Texture Generator's actual NumPy generators created the small wall tiles from
its stone, concrete, plaster and metal recipes. Boneglass rasterized the
window designs directly at 32×48 with one sample per pixel. The facade app's
Figure and project APIs authored thousands of editable elements on an integer pixel
grid. Building Texturing's ShapeOp/Recipe engine composited and saved each
facade. Final PNGs use a maximum of 64 colours, without dithering.

The reproducible build scripts are `examples/pack_assets.py`,
`examples/pack_facades.py`, `examples/pack_texture_export.py` and
`examples/pack_finish.py` in the facade workspace. They use existing local
dependencies and sibling projects. No downloads or external image assets were
used. PNGs are independent of these tools; editing and rebuilding need them.

Asset 001, **The Bay House**, has an individually composed asymmetric layout:
a projecting paired-window bay, narrow stair hall, principal balcony and a
lit side entrance. Run `examples/pack_signature_facade.py` after the general
layout generator and before exporting to retain this revision. The remaining
99 are procedural variations; they have not yet received this individual
design pass.
