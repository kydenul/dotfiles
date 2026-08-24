# Tencent PPT Template - Complete Design Specification

## Slide Dimensions

- **Canvas**: 1920 x 1080 px (16:9 widescreen)
- **Original PPT EMU**: 12,192,000 x 6,858,000 EMU
- **Conversion factor**: 1 EMU = 0.15748 px (at 1920px width)

## Color Palette

### Tencent Blue (Primary Brand Color)

| Name | Hex | Usage |
|------|-----|-------|
| Tencent Blue | `#0052D9` | Primary brand color, section labels, headers |
| Tencent Blue Dark | `#0338D2` | Darkest chart color, accents |
| Tencent Blue Variant | `#0538D0` | Content page center title |
| Tencent Blue BG | `#0052DA` | Ending page solid background |

### Blue Gradient Scale (for charts and graphics)

| Step | Hex | Usage |
|------|-----|-------|
| 1 (darkest) | `#0338D2` | Primary data series |
| 2 | `#265CDA` | Secondary data series |
| 3 | `#5482E2` | Tertiary data series |
| 4 | `#6D94E4` | Quaternary data series |
| 5 | `#A5BFF1` | Light accent |
| 6 (lightest) | `#DFEBFA` | Background accent, light fill |

### Multicolor Palette (alternative theme)

| Name | Hex | Usage |
|------|-----|-------|
| Blue | `#0052D9` | Primary |
| Orange | `#FF7535` | Accent 1 |
| Green | `#9BCF3F` | Accent 2 |
| Cyan | `#3DC0DB` | Accent 3 |

### Neutral Colors

| Name | Hex | Usage |
|------|-----|-------|
| Viewport Dark | `#1a1a2e` | Slide viewport background, body background |
| Black | `#000000` | Body text (dark mode) |
| Dark Gray | `#44546A` | Secondary text |
| Medium Gray | `#797979` | TOC item text, muted text |
| Light Gray | `#D7D7D6` | Borders, subtle backgrounds |
| Lighter Gray | `#E7E6E6` | Background fills |
| Gray C3 | `#C3C3C3` | Decorative elements |
| White | `#FFFFFF` | Text on dark backgrounds, page backgrounds |

### Footer/Page Number Color

- 75% luminance-modulated white: `rgba(255, 255, 255, 0.75)` on dark backgrounds
- 75% luminance gray: `#BFBFBF` on light backgrounds

## Typography

### Font Family Stack

```css
/* Primary - TencentSans (loaded via @font-face) */
@font-face {
  font-family: 'TencentSans';
  src: url('assets/fonts/TencentSans-W3.ttf') format('truetype');
  font-weight: 300;
  font-style: normal;
}

@font-face {
  font-family: 'TencentSans';
  src: url('assets/fonts/TencentSans-W7.ttf') format('truetype');
  font-weight: 700;
  font-style: normal;
}

/* Fallback stack — TencentSans is ALWAYS primary for ALL text */
--font-primary: 'TencentSans', 'Microsoft YaHei', 'PingFang SC', sans-serif;
```

### Type Scale & Minimum Font Sizes

The table below is the **single source of truth** for all font sizes. The "Recommended" column is the default value to use; the "Minimum" column is the absolute floor — never go below it. When creating custom elements not listed here, choose the closest match and use at least its minimum.

**Design rationale**: The canvas is 1920x1080px, but on a MacBook screen (1440px logical width) the scale factor is ~0.75. Font sizes are deliberately generous so that even at 0.75x scale, all text remains clearly readable during live presentations. A 32px body text becomes ~24px visually on a MacBook — adequate for a 3–5 meter viewing distance.

| Token / Element | Recommended | Minimum | Weight | Usage |
|----------------|-------------|---------|--------|-------|
| `--text-thanks` | 120px | 120px | 700 | Ending page "Thanks" text |
| `--text-stat-number` | 96px | 80px | 700 | Statistics large numbers (e.g., "98%", "2.5M") |
| `--text-content-center` | 72px | 64px | 700 | Content page large centered title |
| `--text-cover-title` | 72px | 64px | 700 | Cover slide main title |
| `--text-section-title` | 60px | 52px | 700 | Section divider main title |
| `--text-section-number` | 52px | 48px | 700 | Section divider number |
| `--text-slide-heading` | 48px | 44px | 700 | Content slide main heading |
| `--text-cover-subtitle` | 48px | 44px | 700 | Cover slide subtitle |
| `--text-quote-text` | 48px | 44px | 700 | Large quote text |
| `--text-card-title` | 38px | 34px | 700 | Card / box title text |
| `--text-column-title` | 38px | 34px | 700 | Two-column layout headings |
| `--text-card-icon` | 40px | 36px | 700 | Card icon numbers (01, 02, ...) |
| `--text-section-desc` | 32px | 30px | 400 | Section divider description text |
| `--text-toc-title` | 32px | 30px | 700 | Table of contents section titles |
| `--text-toc-number` | 52px | 48px | 700 | TOC large section numbers (01, 02...) |
| `--text-body` | 32px | 28px | 400 | Default body text, paragraphs |
| `--text-stat-label` | 30px | 28px | 400 | Statistics labels |
| `--text-comparison-label` | 32px | 28px | 700 | Comparison column headers |
| `--text-quote-attribution` | 30px | 28px | 400 | Quote source / attribution |
| `--text-card-desc` | 28px | 26px | 400 | Card description text |
| `--text-timeline-heading` | 30px | 28px | 700 | Timeline phase headings |
| `--text-toc-desc` | 28px | 26px | 400 | TOC section description text |
| `--text-timeline-desc` | 26px | 24px | 400 | Timeline phase descriptions |
| `--text-toc-item` | 26px | 24px | 700 | TOC chapter items |
| `--text-section-label` | 26px | 24px | 700 | Small section labels on content slides |
| `--text-chart-caption` | 24px | 22px | 400 | Chart/image captions and sources |
| `--text-grid-caption` | 24px | 22px | 400 | Image grid captions |
| `--text-badge` | 24px | 22px | 700 | Badge numbers |
| `--text-timeline-date` | 24px | 22px | 700 | Timeline date labels |
| `--text-footer` | 14px | 14px | 300 | Page number, footer text (sole exception) |

**Rules**:
- No visible text on a slide should be smaller than **22px**, except page numbers and footer text (floor: **14px**).
- When generating slides, use the **Recommended** value by default. Only reduce toward the Minimum when space is genuinely constrained.
- Font sizes in `layout-patterns.md` templates must match this table exactly. If a template value differs, this table takes precedence.
- **Presentation readability test**: Mentally apply a 0.75x scale factor to every font size. If the result would be hard to read at 3–5 meters, increase the size.

**Font family rule**: ALL text on every slide MUST use `'TencentSans'` as the primary font. Never set `font-family` to `'Microsoft YaHei'` or any other font as primary — those are fallbacks only, applied automatically via the font stack on `.slide`.

### Text Colors by Context

| Context | Color | Font |
|---------|-------|------|
| Cover title | `#FFFFFF` | TencentSans W7 |
| Cover subtitle | `#FFFFFF` | TencentSans W7 |
| Section divider title | `#0052D9` | TencentSans W7 |
| Section number | `#FFFFFF` | TencentSans W7 |
| Content center title | `#0538D0` | TencentSans W7 |
| Section label (small) | `#0052D9` | TencentSans W7 |
| Slide heading | `#0052D9` | TencentSans W7 |
| TOC section title | `#0052D9` | TencentSans W7 |
| TOC items | `#797979` | TencentSans W7 |
| Sub-labels | `#0052D9` | TencentSans W7 |
| Body text | `#000000` | TencentSans W3 |
| Footer / page number | `#BFBFBF` | TencentSans W3 |
| White-on-blue text | `#FFFFFF` | TencentSans W7 |

## Layout Positioning (1920x1080 scale)

All positions below are translated from EMU to pixels at 1920x1080 resolution.

### Cover Slide

| Element | Position (x, y) | Size (w, h) |
|---------|-----------------|-------------|
| Background image | 0, 0 | 1920, 1080 |
| Pattern overlay | 0, 0 | 1920, 1080 |
| Tencent Logo | 117, 162 | 308, 42 |
| Title | 98, 262 | 1692, 158 |
| Subtitle | 98, 447 | 1424, 153 |

### Section Divider

| Element | Position (x, y) | Size (w, h) |
|---------|-----------------|-------------|
| Background | 0, 0 | 1920, 1080 |
| Pattern overlay | 0, 0 | 1920, 1080 (opacity: 0.15) |
| Section content group | 92, vertically centered | — |
| Section number circle | — | 88, 88 |
| Section number | centered in circle | — |
| Title | right of circle, gap 24px | max-width: 1200px |
| Page indicator | 17, 1042 | 61, 44 |

### Content Page (with section header)

| Element | Position (x, y) | Size (w, h) |
|---------|-----------------|-------------|
| Badge circle | 59, 54 | 48, 48 |
| Section label | 112, 55 | 237, 49 |
| Main heading | 98, 110 | — | — |
| Content area | 98, 180 | 1724, 830 |
| Footer bar | 0, 1030 | 1920, 50 |
| Page number | 17, 1038 | 56, 41 |

### Table of Contents

| Element | Position (x, y) | Size (w, h) |
|---------|-----------------|-------------|
| Badge circle | 59, 54 | 48, 48 |
| Section label | 112, 55 | 237, 49 |
| TOC items start | 200, 250 | — | — |
| Item spacing | — | 60px vertical gap |

### Ending Page

| Element | Position (x, y) | Size (w, h) |
|---------|-----------------|-------------|
| Background (solid) | full | `#0052DA` |
| Pattern overlay | 0, 0 | 1920, 1080 |
| "Thanks" text | center | centered, y≈316 |
| Tencent Logo | 78, 975 | 231, 31 |

## Key Spacing Constants

These spacing values are used in layout templates and should be referenced (not redefined) when building custom layouts:

| Constant | Value | Usage |
|----------|-------|-------|
| Page margin X | 98px | Left/right content margins |
| Page margin Y | 48px | Top margin to badge |
| Header height | 160px | Space reserved for header area |
| Footer height | 50px | Footer bar height |
| Content top | 180px | Top edge of main content area |
| Content bottom | 1030px | Bottom edge of main content area |

> **Note**: The template does NOT use CSS Custom Properties (`:root` variables) in generated slides. All values are hardcoded directly in `styles.css`. The token names in the Type Scale table (e.g., `--text-card-title`) are **reference labels only** — use the corresponding pixel values directly in CSS.

## Background Patterns

The template includes several decorative pattern overlays for cover and ending slides. These are PNG images with transparency:

| Pattern | Asset File | Usage |
|---------|-----------|-------|
| Grid | `assets/media/pattern-grid.png` | Cover style A, Ending style A |
| Blocks | `assets/media/pattern-blocks.png` | Cover style B, Ending style B |
| Stripes | `assets/media/pattern-stripes.png` | Cover style C, Ending style C |
| Light effect | `assets/media/pattern-light.png` | Cover style D, Ending style D |
| Ending grid | `assets/media/ending-pattern-grid.png` | Ending page overlay |
| Ending blocks | `assets/media/ending-pattern-blocks.png` | Ending page overlay |

## Tencent Logo Assets

| File | Description |
|------|-------------|
| `assets/media/tencent-logo-white.png` | White logo for dark backgrounds |
| `assets/media/tencent-logo-white-2.png` | White logo variant |
| `assets/media/tencent-logo-blue.png` | Blue logo for light backgrounds |

## Section Divider Decorative Elements

| File | Description |
|------|-------------|
| `assets/media/section-block-bg.png` | Tencent brand illustration (person/laptop/arrows) for section divider accent — position to the right, low opacity |
| `assets/media/section-stripe-bg.png` | Stripe pattern for section divider background (very large image — use with caution, may cause slow loading) |
| `assets/media/footer-bar.png` | Decorative footer bar for content slides |

**Recommended approach**: Use the cover pattern images (`pattern-grid.png`, `pattern-blocks.png`, etc.) as section divider backgrounds at moderate opacity (0.15). They provide visible texture without overwhelming the content. The `section-block-bg.png` illustration works better as a right-positioned decorative accent (opacity 0.18) than as a full background.

## z-index Layering Convention

All content slides must follow a consistent stacking order:

| Layer | z-index | Elements |
|-------|---------|----------|
| Base content | auto (0) | Normal slide content |
| Footer | `1` | `.slide-footer` and its children |
| Near-footer content | `2` | Legends, bottom callout bars, any absolutely-positioned content within 120px of the slide bottom |

This prevents the footer decorative bar from obscuring content elements like chart legends or summary bars.

## Space Utilization Guidelines

The usable content area spans from **top ~180px** (below header) to **bottom ~1030px** (above footer), giving **~850px** of vertical space.

- Maximum gap between the lowest content element and the footer: **120px**
- Content should occupy at least **80%** of the available vertical space (~680px out of ~850px)
- When content doesn't fill the area, apply fixes in this priority order:
  1. Increase element padding and height (e.g., card boxes, info blocks)
  2. Increase font sizes (body text, descriptions)
  3. Increase spacing between sections
  4. Add a bottom callout bar, summary quote, or key-takeaway strip
- For vertically stacked sections, distribute whitespace **evenly** between sections rather than accumulating at the bottom

## Layout Integrity

All content must stay within the 1920×1080 canvas boundary. After generating each slide, verify:

### Boundary Check

- Every absolutely-positioned element's bounding box `(left, top, left+width, top+height)` must fall within `(0, 0, 1920, 1080)`
- Account for padding and border when calculating effective dimensions
- Text with `overflow: hidden` is acceptable only if intentional (e.g., decorative fade)

### Overlap Check

- Non-nested sibling elements must not have overlapping bounding boxes
- Minimum clearance between adjacent elements: **8px** horizontal, **8px** vertical
- Exception: intentional overlap for decorative layering (e.g., badge on card corner) — must be explicitly noted in comments

### Common Violations and Fixes

| Violation | Fix |
|-----------|-----|
| Text overflows right edge | Reduce font-size or shorten text, increase container width |
| Cards overlap vertically | Increase vertical spacing or reduce card count per row |
| Bottom content hidden by footer | Move content up or reduce element heights |
| Absolute-positioned labels collide | Adjust position values, shorten label text to 4–6 characters |
