// Claude Starfield — * stars + floating Claude avatars
// Normal (orange), Winter Frost (icy blue + * snowflakes), Party Hat (*, /, \ glyphs)
// All avatars randomly rotated.

const float STAR_COUNT       = 25.0;
const float CLAUDE_NORMAL    = 2.0;
const float CLAUDE_WINTER    = 1.0;
const float CLAUDE_HAT       = 2.0;
const float DRIFT_SPEED      = 0.012;
const float STAR_BRIGHTNESS  = 0.38;
const float CLAUDE_BRIGHTNESS= 0.265;  // ~5% more transparent
const float threshold        = 0.15;

const vec3 CLAUDE_ORANGE = vec3(0.851, 0.467, 0.341);
const vec3 WARM_WHITE    = vec3(0.95, 0.92, 0.88);
const vec3 ICE_BLUE      = vec3(0.565, 0.792, 0.976);
const vec3 ICE_WHITE     = vec3(0.890, 0.949, 0.992);

float hash(float n) { return fract(sin(n) * 43758.5453123); }
float luminance(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }

// =====================================================
// Star (*) — 5w × 7h
// =====================================================
int starRow(int y) {
    if (y == 0) return 4;    // ..X..
    if (y == 1) return 21;   // X.X.X
    if (y == 2) return 14;   // .XXX.
    if (y == 3) return 31;   // XXXXX
    if (y == 4) return 14;   // .XXX.
    if (y == 5) return 21;   // X.X.X
    return 4;                // ..X..
}

bool hitStar(vec2 lp, float sz) {
    float cw = sz, ch = sz * 1.4;
    if (lp.x < 0.0 || lp.x >= cw || lp.y < 0.0 || lp.y >= ch) return false;
    int gx = int(lp.x / cw * 5.0);
    int gy = int(lp.y / ch * 7.0);
    return ((starRow(gy) >> (4 - gx)) & 1) == 1;
}

// =====================================================
// / glyph — 5w × 5h
//   ....X  1 | ...X.  2 | ..X..  4 | .X...  8 | X....  16
// =====================================================
int slashLRow(int y) {
    if (y == 0) return 1;
    if (y == 1) return 2;
    if (y == 2) return 4;
    if (y == 3) return 8;
    return 16;
}

bool hitSlashL(vec2 lp, float sz) {
    if (lp.x < 0.0 || lp.x >= sz || lp.y < 0.0 || lp.y >= sz) return false;
    int gx = int(lp.x / sz * 5.0);
    int gy = int(lp.y / sz * 5.0);
    return ((slashLRow(gy) >> (4 - gx)) & 1) == 1;
}

// =====================================================
// \ glyph — 5w × 5h
//   X....  16 | .X...  8 | ..X..  4 | ...X.  2 | ....X  1
// =====================================================
int slashRRow(int y) {
    if (y == 0) return 16;
    if (y == 1) return 8;
    if (y == 2) return 4;
    if (y == 3) return 2;
    return 1;
}

bool hitSlashR(vec2 lp, float sz) {
    if (lp.x < 0.0 || lp.x >= sz || lp.y < 0.0 || lp.y >= sz) return false;
    int gx = int(lp.x / sz * 5.0);
    int gy = int(lp.y / sz * 5.0);
    return ((slashRRow(gy) >> (4 - gx)) & 1) == 1;
}

// =====================================================
// Claude avatar — 18w × 5h (exact block-art subpixels)
// =====================================================
int claudeRow(int y) {
    if (y == 0) return 32760;   // fixed: symmetric head top
    if (y == 1) return 28632;
    if (y == 2) return 131070;
    if (y == 3) return 32760;
    return 10320;
}

bool hitClaudeBase(vec2 lp, float sz) {
    float cw = sz, ch = sz * 10.0 / 18.0;
    if (lp.x < 0.0 || lp.x >= cw || lp.y < 0.0 || lp.y >= ch) return false;
    int gx = int(lp.x / cw * 18.0);
    int gy = int(lp.y / ch * 5.0);
    return ((claudeRow(gy) >> (17 - gx)) & 1) == 1;
}

// 5 avatars spread across screen in a non-symmetric grid pattern
// Each zone is a region; avatar gets a base position + jitter within it
vec2 avatarZone(float idx, float seed) {
    // Hand-picked zones to look well-distributed but not symmetric
    // Arranged roughly as a 3x2 grid with offsets
    vec2 base;
    if (idx < 0.5)      base = vec2(0.16, 0.28);  // upper-left
    else if (idx < 1.5)  base = vec2(0.82, 0.22);  // upper-right
    else if (idx < 2.5)  base = vec2(0.50, 0.50);  // center
    else if (idx < 3.5)  base = vec2(0.22, 0.78);  // lower-left
    else                  base = vec2(0.75, 0.72);  // lower-right
    // Jitter within zone (±10% of screen)
    base.x += (hash(seed) - 0.5) * 0.14;
    base.y += (hash(seed + 1.0) - 0.5) * 0.14;
    return base;
}

// Rotate local coords around glyph center
vec2 rotateLP(vec2 fc, vec2 origin, float cw, float ch, float ang) {
    vec2 ctr = origin + vec2(cw * 0.5, ch * 0.5);
    vec2 d = fc - ctr;
    float ca = cos(ang), sa = sin(ang);
    return vec2(d.x*ca + d.y*sa, -d.x*sa + d.y*ca) + vec2(cw*0.5, ch*0.5);
}

// =====================================================
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec3 col = vec3(0.0);

    // --- Background Stars (*) ---
    for (float i = 0.0; i < STAR_COUNT; i++) {
        float s = i * 13.37;
        float sz = 14.0 + hash(s + 5.0) * 10.0;
        float a = hash(s + 4.0) * 6.2832;
        float t = iTime * DRIFT_SPEED;
        vec2 p = fract(vec2(hash(s), hash(s+1.0))
                 + vec2(cos(a), sin(a)) * t * (0.2 + 0.5*hash(s+6.0)));
        vec2 lp = fragCoord - p * iResolution.xy;
        if (hitStar(lp, sz)) {
            float tw = 0.6 + 0.4*sin(iTime*(0.3+hash(s+3.0)*0.8) + hash(s+3.0)*6.28);
            col += ((hash(s+2.0) < 0.7) ? CLAUDE_ORANGE : WARM_WHITE) * STAR_BRIGHTNESS * tw;
        }
    }

    // --- Normal Claudes (orange, randomly rotated) ---
    for (float i = 0.0; i < CLAUDE_NORMAL; i++) {
        float s = (i + 100.0) * 17.53;
        float globalIdx = i;  // indices 0, 1
        float sz = 95.0 + hash(s+4.0) * 20.0;
        float ang = (hash(s+8.0) - 0.5) * 0.5236;  // ±15 degrees
        float da = hash(s+3.0) * 6.2832;
        float t = iTime * DRIFT_SPEED * 0.5;
        vec2 p = fract(avatarZone(globalIdx, s) + vec2(cos(da),sin(da))*t*0.25);
        vec2 origin = p * iResolution.xy;
        float cw = sz, ch = sz * 10.0 / 18.0;
        vec2 lp = rotateLP(fragCoord, origin, cw, ch, ang);
        if (hitClaudeBase(lp, sz)) {
            float tw = 0.8 + 0.2*sin(iTime*0.4 + hash(s+5.0)*6.28);
            col += CLAUDE_ORANGE * CLAUDE_BRIGHTNESS * tw;
        }
    }

    // --- Winter Frost Claude (icy blue + subtle * snowflakes) ---
    for (float i = 0.0; i < CLAUDE_WINTER; i++) {
        float s = (i + 200.0) * 23.17;
        float globalIdx = CLAUDE_NORMAL + i;  // index 2
        float sz = 90.0 + hash(s+4.0) * 20.0;
        float ang = (hash(s+8.0) - 0.5) * 0.5236;  // ±15 degrees
        float da = hash(s+3.0) * 6.2832;
        float t = iTime * DRIFT_SPEED * 0.45;
        vec2 p = fract(avatarZone(globalIdx, s) + vec2(cos(da),sin(da))*t*0.2);
        vec2 origin = p * iResolution.xy;
        float cw = sz, ch = sz * 10.0 / 18.0;
        vec2 ctr = origin + vec2(cw*0.5, ch*0.5);
        vec2 lp = rotateLP(fragCoord, origin, cw, ch, ang);
        float tw = 0.8 + 0.2*sin(iTime*0.35 + hash(s+5.0)*6.28);

        if (hitClaudeBase(lp, sz)) {
            vec3 wc = mix(ICE_BLUE, ICE_WHITE, hash(s+6.0)*0.4);
            col += wc * CLAUDE_BRIGHTNESS * tw;
        }

        // Subtle * snowflakes scattered around
        for (float j = 0.0; j < 5.0; j += 1.0) {
            float ss = s + j * 7.77;
            float ssz = 8.0 + hash(ss) * 6.0;
            vec2 soff = (vec2(hash(ss+1.0), hash(ss+2.0)) - 0.5) * sz * 2.2;
            vec2 slp = fragCoord - (ctr + soff);
            if (hitStar(slp, ssz)) {
                float stw = 0.6 + 0.4*sin(iTime*(0.4+hash(ss+3.0)) + hash(ss+4.0)*6.28);
                col += WARM_WHITE * 0.15 * stw;
            }
        }
    }

    // --- Party Hat Claudes (*, /, \ character glyphs + face) ---
    for (float i = 0.0; i < CLAUDE_HAT; i++) {
        float s = (i + 300.0) * 31.71;
        float globalIdx = CLAUDE_NORMAL + CLAUDE_WINTER + i;  // indices 3, 4
        float sz = 95.0 + hash(s+4.0) * 20.0;
        float ang = (hash(s+8.0) - 0.5) * 0.5236;  // ±15 degrees
        float da = hash(s+3.0) * 6.2832;
        float t = iTime * DRIFT_SPEED * 0.48;
        vec2 p = fract(avatarZone(globalIdx, s) + vec2(cos(da),sin(da))*t*0.22);

        // Hat character glyph sizing
        float charSz = sz * 0.12;
        float starGH = charSz * 1.4;   // star glyph height (5x7 aspect)
        float slashGH = charSz;         // slash glyph height (5x5 aspect)
        float gap = charSz * 0.3;

        // Layout: star | gap | /\ | gap | face
        float hatH = starGH + gap + slashGH + gap;
        float faceW = sz;
        float faceH = sz * 10.0 / 18.0;
        float totalH = hatH + faceH;

        // Rotation around total bounding box center
        vec2 origin = p * iResolution.xy;
        vec2 boxCtr = origin + vec2(faceW * 0.5, totalH * 0.5);
        vec2 d = fragCoord - boxCtr;
        float ca = cos(ang), sa = sin(ang);
        vec2 rd = vec2(d.x*ca + d.y*sa, -d.x*sa + d.y*ca);
        vec2 lp = rd + vec2(faceW * 0.5, totalH * 0.5);

        float tw = 0.8 + 0.2*sin(iTime*0.38 + hash(s+5.0)*6.28);
        bool hit = false;

        // Face (bottom portion of bounding box)
        vec2 faceLp = vec2(lp.x, lp.y - hatH);
        if (!hit && faceLp.x >= 0.0 && faceLp.x < faceW && faceLp.y >= 0.0 && faceLp.y < faceH) {
            int gx = int(faceLp.x / faceW * 18.0);
            int gy = int(faceLp.y / faceH * 5.0);
            if (((claudeRow(gy) >> (17 - gx)) & 1) == 1) hit = true;
        }

        // Star (*) at top center
        if (!hit) {
            vec2 sp = vec2(faceW * 0.5 - charSz * 0.5, 0.0);
            if (hitStar(lp - sp, charSz)) hit = true;
        }

        // Single /\ row
        if (!hit) {
            float sY = starGH + gap;
            if (hitSlashL(lp - vec2(faceW*0.35 - charSz*0.5, sY), charSz)) hit = true;
            if (!hit && hitSlashR(lp - vec2(faceW*0.65 - charSz*0.5, sY), charSz)) hit = true;
        }

        if (hit) col += CLAUDE_ORANGE * CLAUDE_BRIGHTNESS * tw;
    }

    // --- Blend with terminal ---
    vec4 tc = texture(iChannel0, uv);
    float mask = 1.0 - step(threshold, luminance(tc.rgb));
    fragColor = vec4(mix(tc.rgb, tc.rgb + col, mask), tc.a);
}
