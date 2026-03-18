# sweet-claude-shade

A custom [Ghostty](https://ghostty.org/) shader featuring drifting `*` stars and floating [Claude Code](https://github.com/anthropics/claude-code) avatars on a pure black background. Non-distracting, slow-moving, and weirdly calming.

![ghostty](https://img.shields.io/badge/ghostty-shader-D97757?style=flat-square) ![glsl](https://img.shields.io/badge/pure-GLSL-333?style=flat-square) ![license](https://img.shields.io/badge/license-MIT-blue?style=flat-square)

<img width="1512" height="949" alt="Screenshot 2026-03-18 at 8 12 38 PM" src="https://github.com/user-attachments/assets/4a12efa5-3dd2-45bc-a210-f1a5ae01fe67" />


## Features

- **Twinkling `*` stars** in Claude orange and warm white
- **Three avatar variants** — classic orange, winter frost (icy blue + snowflakes), and party hat (`/\` cone with `*` tip)
- **Pixel-perfect Claude avatar** encoded from the original Unicode block art
- **Zone-distributed placement** — avatars spread evenly across the screen
- Everything rendered as bitmap glyphs in pure GLSL — no textures, no external assets

```
       *
     /   \
    ▐▛███▜▌
   ▝▜█████▛▘
     ▘▘ ▝▝
```

## Install

```bash
git clone git@github.com:mrsladoje/sweet-claude-shade.git
mkdir -p ~/.config/ghostty/shaders
cp sweet-claude-shade/starfield.glsl ~/.config/ghostty/shaders/
```

Add to `~/.config/ghostty/config`:

```ini
background = 000000
foreground = ffffff
custom-shader = shaders/starfield.glsl
custom-shader-animation = true
```

Restart Ghostty.

## Variants

| File | Description |
|------|-------------|
| `starfield.glsl` | Stars + Claude avatars (normal, winter frost, party hat) |
| `starfield-glow.glsl` | Minimal glowing starfield, no avatars |

## Configuration

All parameters are at the top of `starfield.glsl`:

```glsl
const float STAR_COUNT       = 25.0;   // number of * stars
const float CLAUDE_NORMAL    = 2.0;    // orange Claude avatars
const float CLAUDE_WINTER    = 1.0;    // icy blue winter edition
const float CLAUDE_HAT       = 2.0;    // party hat edition
const float DRIFT_SPEED      = 0.012;  // movement speed
const float STAR_BRIGHTNESS  = 0.38;   // star opacity
const float CLAUDE_BRIGHTNESS= 0.265;  // avatar opacity
```

## How It Works

The Claude avatar is a subpixel-accurate mapping of the Unicode block art `▐▛███▜▌ / ▝▜█████▛▘ / ▘▘ ▝▝`. Each block character is decomposed into 2x2 quadrant pixels, producing an 18x5 bitmap rendered with terminal-correct aspect ratio. Stars, slashes, and the avatar are all encoded as integer bit patterns and rasterized per-fragment.

## Requirements

- [Ghostty](https://ghostty.org/) 1.2.0+

## Credits

Built by [@mrsladoje](https://github.com/mrsladoje). Starfield base inspired by [ghostty-shaders](https://github.com/hackr-sh/ghostty-shaders). Avatar variants inspired by [claude-skins](https://github.com/ClaudevGuy/claude-skins).

## License

MIT
