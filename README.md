# sweet-claude-shade

> Because your terminal deserves to feel like the inside of Claude's fever dream.

A custom [Ghostty](https://ghostty.org/) shader that fills your terminal background with gently drifting `*` stars and floating Claude avatars — the little `▐▛███▜▌` blobs you know and love from [Claude Code](https://github.com/anthropics/claude-code).

No productivity was harmed in the making of this shader. (That's a lie.)

![ghostty-shader](https://img.shields.io/badge/ghostty-shader-D97757?style=flat-square) ![vibe](https://img.shields.io/badge/vibe-immaculate-blue?style=flat-square) ![stars](https://img.shields.io/badge/%E2%9C%A8_stars-yes_literally-yellow?style=flat-square)

## What You Get

- **`*` shaped stars** — 25 softly twinkling asterisks in Claude orange and warm white, drifting across a pitch-black void like your motivation on a Monday
- **Orange Claude avatars** — the classic blob, pixel-perfect from the original block art, slightly tilted like they've had one too many API calls
- **Winter Frost Claude** — an icy-blue edition surrounded by `*` snowflakes, because even AI deserves a holiday
- **Party Hat Claude** — wearing a `*`-tipped `/\` cone hat, eternally celebrating the fact that you chose Ghostty
- All avatars are **zone-distributed** across your screen so nobody's lonely, gently rotating ±15° like bobbleheads on a dashboard

## Preview

```
         *            ← party hat star
       /   \          ← actual / and \ glyphs
     /       \
    ▐▛███▜▌           ← Claude avatar (solid, no eyes — NOT the Android robot)
   ▝▜█████▛▘
     ▘▘ ▝▝            ← feet
```

## Installation

### 1. Clone this bad boy

```bash
git clone git@github.com:mrsladoje/sweet-claude-shade.git
```

### 2. Copy the shader

```bash
mkdir -p ~/.config/ghostty/shaders
cp sweet-claude-shade/starfield.glsl ~/.config/ghostty/shaders/
```

### 3. Add to your Ghostty config

Add these lines to `~/.config/ghostty/config`:

```ini
# Fully black background (required — stars need darkness)
background = 000000
foreground = ffffff

# The shader
custom-shader = shaders/starfield.glsl
custom-shader-animation = true
```

### 4. Restart Ghostty

Close and reopen Ghostty. Bask in the glory.

## Variants

This repo includes two shader files:

| File | Description |
|------|-------------|
| `starfield.glsl` | The full experience — stars + Claude avatars (normal, winter, party hat) |
| `starfield-glow.glsl` | A simpler glowing starfield without avatars — for the minimalists among us |

To switch between them, change the `custom-shader` path in your Ghostty config.

## Tuning

All the knobs are at the top of `starfield.glsl`:

```glsl
const float STAR_COUNT       = 25.0;   // number of * stars
const float CLAUDE_NORMAL    = 2.0;    // orange Claude faces
const float CLAUDE_WINTER    = 1.0;    // icy blue winter Claudes
const float CLAUDE_HAT       = 2.0;    // party hat Claudes
const float DRIFT_SPEED      = 0.012;  // how fast everything floats
const float STAR_BRIGHTNESS  = 0.38;   // star opacity
const float CLAUDE_BRIGHTNESS= 0.265;  // avatar opacity
```

Crank `CLAUDE_NORMAL` to 20 if you want an army. Set `DRIFT_SPEED` to 0 if you want them frozen in place. Set `CLAUDE_BRIGHTNESS` to 1.0 if you want to see nothing but Claude. We don't judge.

## How It Works

The shader renders bitmap glyphs entirely in GLSL — no textures, no external assets. Each character (`*`, `/`, `\`, and the Claude avatar) is encoded as integer bit patterns and rasterized per-fragment. The Claude avatar is a pixel-perfect subpixel mapping of the Unicode block art:

```
 ▐▛███▜▌
▝▜█████▛▘
  ▘▘ ▝▝
```

Each block character (▐, ▛, █, ▜, ▌, ▝, ▘) is decomposed into its 2×2 quadrant subpixels, producing an 18×5 pixel bitmap rendered with 2:1 vertical stretch to match terminal character aspect ratio.

The party hat uses actual `/` and `\` character bitmap glyphs arranged in a cone with a `*` at the tip. Because if you're going to over-engineer a terminal shader, you might as well go all the way.

## Requirements

- [Ghostty](https://ghostty.org/) terminal (1.2.0+ with custom shader support)
- A deep appreciation for unnecessary beauty

## Credits

Crafted with love by [@mrsladoje](https://github.com/mrsladoje) and Claude (yes, the AI is in the shader AND made the shader — it's turtles all the way down).

Starfield base inspired by [ghostty-shaders](https://github.com/hackr-sh/ghostty-shaders). Avatar skins inspired by [claude-skins](https://github.com/ClaudevGuy/claude-skins).

## License

MIT — do whatever you want. Put Claude on everything.
