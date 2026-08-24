---
name: tencent-ppt
description: This skill should be used when the user asks to "create a presentation", "make slides", "generate PPT", "build a slide deck", "create Tencent slides", "make a PPT page", or discusses presentation generation, slide design, or deck creation. Generates web-based presentation pages following the official Tencent PPT Template design system with support for multimedia content.
version: 3.3.0
author: shiyicao
---

# Tencent PPT Slide Generator

Generate presentation slides as HTML + CSS following the official Tencent PPT Template design system. Output is an `index.html` (slide content) + `styles.css` (all styles) + static `assets/` (fonts, media, slideshow engine). Open in browser via local preview server for full functionality (navigation, gallery, PDF export), or double-click `index.html` for quick preview.

## Workflow

### 1. Gather Requirements

Ask the user:

- **Topic & audience**: What is the presentation about? Who is it for?
- **Slide count & outline**: How many slides? Key sections?
- **Media**: Any images, videos, or GIFs? (local paths or URLs)
- **Color theme**: Blue monochrome (default) or multicolor?

### 2. Plan Slides

Present a structured plan before generating. For each slide, specify a layout type.

**Content density rule**: One core topic per slide. Prefer more focused slides over fewer cramped ones.

**Cover styles**: `cover-grid` / `cover-blocks` / `cover-stripes` / `cover-light` / `cover-blue-solid` / `cover-photo`

**Content layouts**: `title-only` / `content-text` / `content-image-right` / `content-image-left` / `content-full-image` / `content-3-images` / `content-2-column` / `content-cards` / `content-chart` / `content-video` / `content-quote` / `content-comparison` / `content-timeline` / `content-stats`

**Structural**: `toc` / `section-divider` / `ending-thanks`

### 3. Set Up Project

Create the output directory and **hard-link** all static assets from the skill:

```bash
mkdir -p slides-output/assets/{js,fonts,media}
# Hard-link skill assets (fonts, media, app.js) — shared inode, no duplication
ln -f SKILL_DIR/assets/js/app.js slides-output/assets/js/app.js
ln -f SKILL_DIR/assets/fonts/TencentSans-W3.ttf slides-output/assets/fonts/TencentSans-W3.ttf
ln -f SKILL_DIR/assets/fonts/TencentSans-W7.ttf slides-output/assets/fonts/TencentSans-W7.ttf
for f in SKILL_DIR/assets/media/*; do ln -f "$f" slides-output/assets/media/; done
```

**Hard-link user-provided local media** (images, videos, GIFs) into the project:

```bash
# For each local media file the user wants to include:
ln -f /Users/name/photo.jpg slides-output/assets/media/photo.jpg
ln -f /Users/name/demo.mp4 slides-output/assets/media/demo.mp4
```

Then reference them with **relative paths** in HTML: `<img src="assets/media/photo.jpg">`.

Replace `SKILL_DIR` with the actual skill installation path. Use `ln -f` (hard link), not `cp` or `ln -s`:
- Hard links share the same inode — no disk duplication, and both `file://` and HTTP paths work correctly
- Symlinks break under `file://` in many browsers (security restrictions)
- Copying wastes disk (fonts are ~17MB total)
- **Critical for PDF export**: Under `file://`, images from different absolute paths are cross-origin and taint the canvas, breaking `toDataURL()`. Hard-linking into the project makes all media same-origin.

### 4. Generate Files

Generate exactly two files:

| File | Content |
|------|---------|
| `index.html` | All slides as `<div class="slide" data-slide="N">`, linked to `styles.css` and `assets/js/app.js` |
| `styles.css` | `@font-face` declarations + shared styles + per-slide `[data-slide="N"]` scoped rules |

**LLM never touches `assets/`** — those are static skill assets.

See `references/layout-patterns.md` for the complete `index.html` template, `styles.css` template, and all layout patterns.

#### Key Rules

- **Canvas**: Fixed 1920×1080px. The `app.js` engine handles `transform: scale()` to fit any screen. Never resize the `.slide` div.
- **Fonts**: `@font-face` in `styles.css` loads TencentSans-W3/W7. Set `font-family` on `.slide` only — all children inherit. Never override `font-family` on inner elements.
- **Colors**: Use the Tencent brand palette from `references/design-spec.md`.
- **No inline styles/scripts**: All CSS in `styles.css`, all JS in `app.js`. The `index.html` has zero `<style>` or `<script>` blocks (only `<link>` and `<script src>`).
- **CSS scoping**: Shared classes (`.slide-header`, `.badge`, `.content-heading`, etc.) defined once. Per-slide overrides use `[data-slide="N"]` selectors.
- **Active slide**: Exactly one `<div class="slide">` has class `active` (usually the first). `app.js` manages the rest.

#### Space Utilization

Content area: top ~180px to bottom ~1030px (~850px vertical). Fill at least 80%:

1. Increase element padding/height
2. Increase font sizes
3. Increase section spacing
4. Add a bottom callout/summary bar

Max gap between lowest content and footer: **120px**. Near-footer content elements need `z-index: 2` (footer bar has `z-index: 1`).

#### Section Divider Backgrounds

- **Geometric pattern (default)**: Use `pattern-grid.png` / `pattern-blocks.png` / `pattern-stripes.png` / `pattern-light.png` at `opacity: 0.15`. Vary across sections.
- **Illustration accent**: Use `section-block-bg.png` positioned right at `opacity: 0.18`.

#### Layout Integrity

After generating each slide, verify:
1. **Boundary**: All elements within 0–1920 (x) and 0–1080 (y)
2. **Overlap**: Non-nested siblings have ≥8px clearance
3. **Overflow**: Text doesn't overflow containers

#### Custom Diagrams

- Keep labels **4–6 characters** max
- Check bounding-box collisions before positioning
- Use SVG `<path>` for connectors (not Unicode arrows)

### 5. Output Structure

```
slides-output/
├── index.html          # All slides (LLM-generated)
├── styles.css          # All styles (LLM-generated)
└── assets/             # Hard-linked from skill assets + user media
    ├── js/app.js       # Slideshow engine (static)
    ├── fonts/          # TencentSans-W3.ttf, TencentSans-W7.ttf
    └── media/          # Logos, patterns, footer-bar + user images/videos
```

#### Slide Add/Remove Checklist

When adding, removing, or reordering slides:
1. **`data-slide` attributes** — renumber sequentially (1, 2, 3, ...)
2. **Page numbers** — update `.page-number` text in each slide's footer
3. **Section numbers** — update if sections were reordered

### 6. Slideshow Features (provided by `app.js`)

`app.js` is a static engine. It auto-discovers all `.slide` elements and provides:

- **Keyboard navigation**: ← → ↑ ↓ Space Home End
- **Fullscreen**: F key
- **Gallery / overview**: G key or ▦ button — thumbnail grid for quick slide navigation
- **PDF export**: P key or 📄 button (**HTTP mode only** — under `file://` the button is hidden, P key shows a friendly tip)
- **Progress bar** at top
- **Slide counter** (e.g., "3 / 15")
- **Auto-hide control bar** (appears on hover)
- **Viewport scaling**: `transform: scale()` with 300ms polling fallback

Navigation, fullscreen, and gallery work under both `file://` and HTTP. PDF export requires HTTP mode.

### 7. Start Preview Server

After generating files, **start a local HTTP server** so the user can preview with full functionality (including PDF export):

```bash
cd slides-output && python3 -m http.server 8080
```

Then open `http://localhost:8080` in the browser. Tell the user:

> "已启动 PPT 预览，请在浏览器中打开 http://localhost:8080 查看。按 P 键可导出 PDF。"

Alternatively, the user can double-click `index.html` for quick preview (keyboard navigation and gallery work, but PDF export is unavailable).

### 8. Preview

**Recommended**: Use the HTTP server started in Step 7. All features work:
- Keyboard shortcuts ✅
- Fullscreen ✅
- Gallery overview ✅
- PDF export ✅ (needs internet on first use for CDN libraries)

**Fallback**: Open `slides-output/index.html` directly (`file://`). Navigation and gallery work, but PDF export is unavailable.

## Font Size Rules

All font sizes are defined in `references/design-spec.md` (single source of truth). Quick reference:

| Element | Recommended | Minimum |
|---------|-------------|---------|
| Cover title | 72px | 64px |
| Cover subtitle | 48px | 44px |
| Section title | 60px | 52px |
| Slide heading | 48px | 44px |
| Card/column title | 38px | 34px |
| Body text | 32px | 28px |
| Statistics number | 96px | 80px |
| Section label | 26px | 24px |
| Captions / badges | 24px | 22px |
| Page number | 14px | 14px |

**Absolute floor**: No visible text below **22px**, except page numbers (14px).

**Rationale**: On MacBook (scale ~0.75×), 32px body text renders as ~24px — still readable at 3–5m distance.

### Font Family Rule

ALL text uses `'TencentSans'` as primary font, set on `.slide` and inherited by all children. Never override `font-family` on inner elements.

### Post-Generation Audit

1. **Font size audit**: Every `font-size` below 22px (except `.page-number` 14px) is a violation
2. **Consistency audit**: All section dividers use identical styles
3. **Space audit**: Lowest content within 120px of footer on every slide

## PDF Export

Built into `app.js`. Uses html2canvas + jsPDF loaded from CDN on first use. **Requires HTTP mode** (local server).

- Under `file://`: export button is hidden; pressing P shows a friendly tip directing the user to start preview via CodeBuddy
- Under HTTP (`localhost`): P key or 📄 button triggers export
- Internet required on first export (CDN libraries cached after)
- Progress overlay shows capture status
- Temporarily resets `transform: scale()` to capture at full 1920×1080
- PDF filename defaults to `<title>` of `index.html`

## Media Handling

1. **Local files**: Hard-link into `assets/media/` and use relative path — `<img src="assets/media/photo.jpg">`. See Step 3 for the `ln -f` command. **Never use absolute paths** — they break PDF export under `file://` (cross-origin canvas tainting) and make slides non-portable.
2. **URLs**: Use directly — `<img src="https://example.com/img.jpg">`. Note: remote images may fail PDF export under `file://` due to CORS.
3. **Formats**: PNG, JPG, SVG, WebP, GIF (animated), MP4, WebM
4. **Video**: `<video controls autoplay muted loop>` with `<source>`
5. **Sizing**: `object-fit: cover` or `contain` to preserve aspect ratio

**File naming**: When hard-linking user media, preserve the original filename. If conflicts arise, prefix with a short identifier (e.g., `user-photo.jpg`).

## Reference Files

- **`references/design-spec.md`** — Colors, typography scale, spacing, layout integrity rules
- **`references/layout-patterns.md`** — HTML/CSS patterns for all slide types, `index.html` and `styles.css` templates

## Asset Files

- **`assets/js/app.js`** — Slideshow engine (keyboard, fullscreen, gallery overview, PDF export, viewport scaling)
- **`assets/fonts/`** — TencentSans-W3.ttf (light), TencentSans-W7.ttf (bold)
- **`assets/media/`** — Tencent logos, pattern overlays, footer bar, section backgrounds
