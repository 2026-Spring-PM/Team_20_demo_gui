# Candidate tile texture sets

These are NEW texture sets received on 5/26. Files are staged here in
the engine's canonical naming convention so they're drop-in ready.

## What's live
- `dirt_{center,outline,corner,inner,leftright,allinner}.png` -- copied
  to `../tiles/path_*.png`. The auto-tile registry picks them up via
  `terrainPathPrefix(Path) = "tiles/path"`. Every Path tile in
  `world.txt` now renders with this set instead of the flat reddish-
  brown TileAtlas Path row.
- `grass_{leftright,allinner}.png` -- copied to `../tiles/grass_*.png`
  alongside the four core grass pieces that were already live.

## What's staged but not live
- `grass_{center,outline,corner,inner}.png` -- byte-identical to the
  live `tiles/grass_*.png`. Kept here as the canonical "as received"
  archive.
- `street_*.png`, `pedestrian_*.png` -- a designed pair (paved square
  + plain pavement) intended for an urban scene. Adopting them needs
  either (a) new chars in `assets/maps/town.txt` plus new
  `TileType::Street` / `TileType::Pedestrian` enum entries, or
  (b) a scene-aware override that lets the same `TileType::Path`
  resolve to different texture prefixes in village vs town. Both
  are larger changes than just dropping files.

## File-name -> picker-slot mapping (engine canonical)

  <prefix>_center.png    -> AutoTilePiece::Center      (interior cell)
  <prefix>_outline.png   -> AutoTilePiece::Outline     (one cardinal off)
  <prefix>_corner.png    -> AutoTilePiece::Corner      (two adjacent
                                                        cardinals off)
  <prefix>_inner.png     -> AutoTilePiece::InnerCorner (one diagonal off)
  <prefix>_leftright.png -> AutoTilePiece::Strip       (opposite-pair
                                                        cardinal mismatch)
  <prefix>_allinner.png  -> AutoTilePiece::AllInner    (all 4 cardinals
                                                        match, all 4
                                                        diagonals off)

Strip / AllInner are 5/26 v5 additions; the first four predate them.
All six are loaded best-effort -- a terrain that's missing any optional
piece (anything other than center/outline/corner) renders the affected
cells as Center, no crash.

## How to promote one of the staged sets later
1. Pick a `TileType` to point at it.
2. Copy the pieces into `../tiles/<prefix>_*.png` where `<prefix>`
   matches `terrainPathPrefix(<TileType>)` in `src/core/AutoTile.cpp`.
3. Restart the game. `AutoTileRegistry::loadAll()` re-scans on init.
