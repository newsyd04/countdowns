# Countdowns — Design System Specification

> Living document. Updated alongside every UI, interaction, or layout change.

---

## Color System

### Semantic Colors

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `labelPrimary` | `#000000` | `#FFFFFF` | Primary text |
| `labelSecondary` | `#3C3C43` @ 60% | `#EBEBF5` @ 60% | Secondary text |
| `labelTertiary` | `#3C3C43` @ 30% | `#EBEBF5` @ 30% | Tertiary text, placeholders |
| `backgroundPrimary` | `#F2F2F7` | `#000000` | Main background |
| `surfacePrimary` | `#FFFFFF` | `#1C1C1E` | Cards, sheets |
| `surfaceSecondary` | `#F2F2F7` | `#2C2C2E` | Grouped backgrounds |
| `accent` | `#007AFF` | `#0A84FF` | Primary actions, links |
| `destructive` | `#FF3B30` | `#FF453A` | Delete actions |
| `separator` | `#3C3C43` @ 30% | `#545458` @ 60% | Dividers |

### Card Color Palette

12 curated vibrant colors. All use **white text** regardless of background brightness.

| Index | Name | Light | Dark |
|-------|------|-------|------|
| 0 | Coral | `#FF6B6B` | `#FF5252` |
| 1 | Tangerine | `#FF9500` | `#FF9F0A` |
| 2 | Sunflower | `#FFCC02` | `#FFD60A` |
| 3 | Mint | `#34C759` | `#30D158` |
| 4 | Teal | `#5AC8FA` | `#64D2FF` |
| 5 | Ocean | `#007AFF` | `#0A84FF` |
| 6 | Indigo | `#5856D6` | `#5E5CE6` |
| 7 | Purple | `#AF52DE` | `#BF5AF2` |
| 8 | Rose | `#FF2D55` | `#FF375F` |
| 9 | Graphite | `#8E8E93` | `#98989D` |
| 10 | Storm | `#636366` | `#6C6C70` |
| 11 | Midnight | `#1C1C1E` | `#3A3A3C` |

### Dynamic Color Variation

Always active. Each countdown card receives a subtle, deterministic color shift seeded by its unique ID:

- **Hue**: +/-8 degrees
- **Brightness**: +/-5%
- **Saturation**: Clamped above 50% (never muddy)
- **Text color**: Always white (never shifted)

Two cards with the same base color will look subtly different.

---

## Typography Scale

Font: `.SF Pro Display` (system font identifier — resolves to SF Pro on Apple, default sans-serif elsewhere).

| Style | Size | Weight | Tracking | Line Height |
|-------|------|--------|----------|-------------|
| Large Title | 34 | Bold (700) | +0.37 | 1.21 |
| Title 1 | 28 | Bold (700) | +0.36 | 1.21 |
| Title 2 | 22 | Bold (700) | +0.35 | 1.27 |
| Title 3 | 20 | Semibold (600) | +0.38 | 1.25 |
| Headline | 17 | Semibold (600) | -0.41 | 1.29 |
| Body | 17 | Regular (400) | -0.41 | 1.29 |
| Callout | 16 | Regular (400) | -0.32 | 1.31 |
| Subhead | 15 | Regular (400) | -0.24 | 1.33 |
| Footnote | 13 | Regular (400) | -0.08 | 1.38 |
| Caption 1 | 12 | Regular (400) | 0 | 1.33 |
| Caption 2 | 11 | Regular (400) | +0.07 | 1.18 |

### Custom Styles

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| Countdown Large | 48 | Bold | Days remaining number on cards |
| Countdown Unit | 14 | Medium | "days" / "weeks" label below number |

---

## Spacing System

**Strict 8pt grid.** All spacing values are multiples of 8 (with 4pt half-step for optical adjustments).

### Base Scale

| Token | Value | Usage |
|-------|-------|-------|
| `xxs` | 4pt | Optical adjustment (half-step) |
| `xs` / `sm` | 8pt | Minimum standard spacing |
| `md` / `lg` | 16pt | Standard content spacing |
| `xl` / `xxl` | 24pt | Section-level spacing |
| `xxxl` | 32pt | Major section breaks |
| `huge` | 48pt | Hero spacing |
| `massive` | 64pt | Maximum spacing |

### Semantic Spacing

| Token | Value | Usage |
|-------|-------|-------|
| `cardPadding` | 16pt | Internal card padding |
| `listItemSpacing` | 8pt | Gap between list items |
| `sectionSpacing` | 24pt | Gap between major sections |
| `screenHorizontal` | 16pt | Horizontal screen margins |
| `screenVertical` | 16pt | Vertical screen margins |

### Corner Radius Scale

| Level | Value | Usage |
|-------|-------|-------|
| Small | 12pt | Buttons, chips, badges |
| Medium | 16pt | Cards, inputs |
| Large | 20pt | Modals, sheets, pill shapes |

---

## Motion & Animation

### Principles

- All animations are **physics-based** (spring simulations, not fixed-duration eases)
- Motion must feel like manipulating real objects
- No exaggerated bounce — Apple-style damped springs only
- Animate between states, never appear/disappear

### Spring Configurations

| Spring | Mass | Stiffness | Damping | Usage |
|--------|------|-----------|---------|-------|
| Tap | 1.0 | 600 | 30 | Button/card press feedback |
| Gesture | 1.0 | 400 | 28 | Interactive drag/swipe |
| Reorder | 1.0 | 300 | 24 | List reorder card movement |
| Modal | 1.0 | 250 | 22 | Sheet/modal presentations |

### Fallback Curves (non-spring contexts)

| Curve | Flutter Value | Usage |
|-------|-------------|-------|
| Default | `easeOutCubic` | General transitions |
| Deceleration | `easeOutQuart` | Scroll settle |
| Entrance | `easeOutCubic` | Content appearing |
| Exit | `easeInCubic` | Content leaving |

### Scale Values

| Interaction | Scale | Notes |
|-------------|-------|-------|
| Tap press | 0.97 | Subtle press-down feel |
| Drag lift | 1.04 | Card lifts during reorder |
| Parallax boost | 1.02 | Cards near screen center |

### Duration Constants (for non-spring animations)

| Token | Value |
|-------|-------|
| Fast | 150ms |
| Normal | 300ms |
| Slow | 450ms |

---

## Gesture Behavior

### Card Tap

1. Finger down: Spring to 0.97 scale + light haptic
2. Finger up: Spring back to 1.0 + navigate to edit
3. Cancel: Spring back to 1.0

### Swipe Actions (Custom `PhysicsSwipeCard`)

Fully custom physics-based swipe system replacing `flutter_slidable`.

#### Directions
- **Swipe LEFT** → reveal DELETE (red, trash icon)
- **Swipe RIGHT** → reveal EDIT (blue, pencil icon)

#### Resistance Model (Non-Linear)
| Zone | Behavior |
|------|----------|
| 0–8px | Dead zone (prevents accidental swipes) |
| 8px–actionExtent | Free movement, 1:1 finger tracking |
| Beyond actionExtent | Elastic resistance (30% of excess movement) |

#### Snap Thresholds
| Condition | Result |
|-----------|--------|
| Small swipe (< 40% of action extent) | Spring back to center |
| Medium swipe (> 40%) or velocity > 200px/s | Snap to "action revealed" state |
| Fast left swipe (velocity > 800px/s) | Immediate delete trigger |
| Full right swipe | Reveal only (no auto-trigger for edit) |

#### Spring Config
- Mass: 1.0, Stiffness: 350, Damping: 26
- Slight overshoot allowed for natural settle feel

#### Haptics
- Selection haptic when crossing action threshold
- Medium haptic on delete trigger
- Light haptic on edit trigger

#### Visual Integration
- Action panels are behind the card (same border radius)
- Icons + labels scale in (0.8→1.0) as swipe progresses
- Opacity fades in with swipe progress
- Tap targets appear over revealed actions at 50% progress

### Drag Reorder

- Long press to initiate (via `ReorderableDragStartListener`)
- Card scales to 1.04x with elevated shadow
- Other cards reposition smoothly
- Medium haptic on reorder

---

## Navigation Pattern

### Collapsing Glass Navigation Bar

Uses `CupertinoSliverNavigationBar` for layout safety during route transitions. Glass effect is achieved via the framework's internal `BackdropFilter` (activated when `backgroundColor` has alpha < 1.0).

#### Glass Header Calibration

##### Layer Stack

| Layer | Type | Value |
|-------|------|-------|
| 1. Blur | Backdrop blur (framework) | ~10 sigma (CupertinoSliverNavigationBar internal) |
| 2. Neutral tint | Background color overlay | `#F9F9F9` at 78% opacity (light) / `#1C1C1E` at 78% (dark) |
| 3. Depth | No divider, no shadow | `border: Border()` (empty) |
| 4. Content | Title + icons | Standard Cupertino chrome |

##### Color Bleed Control

- Tint color is neutral near-white (#F9F9F9), NOT page background (#F2F2F7)
- 78% opacity neutralizes bright card colors while preserving translucency
- Pure white (#FFFFFF) rejected: too harsh against page background
- Page background (#F2F2F7) rejected: warm tone amplifies card color bleed

##### Scroll Interpolation

Handled natively by CupertinoSliverNavigationBar:
- progress 0.0: Large title, no blur, solid background
- progress 0.5: Mid-transition, blur activating
- progress 1.0: Compact title, full blur, 78% tint overlay

##### Validation

- Green card underneath → header stays neutral ✓
- Red/pink card underneath → header stays neutral ✓
- Yellow card underneath → header stays neutral ✓
- Header still feels translucent (content shapes softly visible) ✓
- Header never appears as solid block ✓

##### Compact Title

- Font: 17pt Semibold (framework default)
- Color: near-black (labelPrimary)

##### Icons

- Size: 22pt
- Color: system blue (accent/accentDark)
- Hit target: 44x44pt
- Spacing: 16pt between gear and "+"

### No FAB

The app does not use a FloatingActionButton. The "+" is always in the nav bar.

---

## Settings Screen

### Navigation

- Accessed via **gear icon** (top-right of home nav bar, secondary to "+")
- Uses `CupertinoPageRoute` (standard iOS push transition)
- Title: "Settings" in `CupertinoNavigationBar`

### Spacing (strict 8pt grid)

| Spacing | Value | Location |
|---------|-------|----------|
| Screen horizontal padding | 16pt | Left/right of all content |
| Top padding (below nav) | 16pt | Before first section header |
| Header → group gap | 8pt | Between section title and container |
| Group → group gap | 24pt | Between sections |
| Last group → footer gap | 32pt | Before credits |

### Section Headers

- **Font**: 13pt, Medium (w500), 0.4 letter spacing
- **Color**: `labelSecondary`
- **Transform**: ALL CAPS
- **Left padding**: 16pt (aligned with row content)

### Group Containers

- **Background**: `surfacePrimary` (no shadow)
- **Border radius**: 16pt
- **Internal padding**: 0 (rows handle their own padding)

### Rows (56pt target height)

| Property | Value |
|----------|-------|
| Horizontal padding | 16pt |
| Vertical padding | 16pt |
| Font size | 17pt |
| Font weight | Regular (w400) |
| Label color | `labelPrimary` |
| Value color | `labelSecondary` |
| Icon size | 22pt |
| Icon → label gap | 12pt |

### Toggles

- **Widget**: `CupertinoSwitch`
- **Active color**: `#34C759` (iOS system green)
- **Animation**: ~200ms, smooth

### Separators

- **Height**: 0.33pt
- **Opacity**: 12% of separator color
- **Left inset**: 50pt (16 padding + 22 icon + 12 gap)
- **Only between rows** (never between groups)

### Footer (Credits)

```
        Version 1.0        — 13pt, Regular, 45% opacity
        Dara Newsome        — 13pt, Regular, 50% opacity
```

- Centered, 32pt above, 24pt below
- Quiet and non-promotional

### Preferences Persistence

Stored in Hive `settings_box`. Preferences provider (`PreferencesNotifier`) reads synchronously on init for instant rendering.

---

## Component Specs

### Countdown Card

- **Background**: Vibrant card color (with dynamic shift)
- **Corner radius**: 16pt (medium)
- **Padding**: 16pt all sides
- **Shadow**: Color-matched, blur 16, offset (0, 4), spread -2
- **Content**: Emoji (48x48) | Title + Date | Days remaining
- **Recurrence badge**: Positioned top-right overlay, 8pt from edges
- **Past cards**: 60% opacity background, lighter shadow

### Section Header

- **Title**: Title3 Semibold
- **Count badge**: Caption1 in pill container (chipRadius)
- **Collapsible**: Chevron icon with animated rotation (0.25 turns)

### Empty State

- Personality-driven messaging
- Pulsing animation on icon
- "Create your first countdown" CTA

### Undo Snackbar

- Floating behavior
- 4 second duration
- Dark background (`#2C2C2E`)
- Accent-colored undo button

---

## App Icon & Branding

### Selected Direction: C — Stacked Days

A vibrant rounded square icon featuring a bold white number on a warm gradient background, directly reflecting the app's countdown card design language.

### Specification

| Property | Value |
|----------|-------|
| Shape | Rounded square (iOS standard superellipse) |
| Gradient start | Coral `#FF6B6B` (top-left) |
| Gradient end | Tangerine `#FF9500` (bottom-right) |
| Gradient angle | 135 degrees |
| Number | Bold white "7" (or chosen numeral), ~55% of icon height |
| Typography | SF Pro Display Bold or geometric sans-serif, white `#FFFFFF` |
| Accent | Subtle white sparkle at 60% opacity, upper-right quadrant |

### Rationale

- **Connects to countdown card visual language.** Every card in the app uses white text on a vibrant color. The icon is essentially a miniature countdown card.
- **Distinctive on the home screen.** The coral-to-tangerine gradient is warm and eye-catching without clashing with common icon colors.
- **White-on-color is the app's core design motif.** Reinforces brand recognition from icon to in-app experience.
- **Works at all sizes.** A single bold number has no fine details to lose at small sizes (29pt, 40pt).

### Asset Requirements

| Platform | Assets | Notes |
|----------|--------|-------|
| iOS | 1024x1024 master PNG (no alpha, no corners) | Xcode generates all sizes from the master |
| Android | Foreground 108dp + background 108dp (adaptive icon) | Content within 66dp safe zone |
| Web | 192x192, 512x512 PNG + maskable variants | For PWA manifest |
| macOS | 1024x1024 PNG | With macOS-specific rounded rect + shadow template |

> Full icon strategy and design tool workflow: [`docs/app_icon.md`](app_icon.md)

---

## Performance

### Device Tier System

| Tier | Parallax | Rich Shadows | Springs | Blur Sigma | Shadow Mult |
|------|----------|-------------|---------|------------|-------------|
| Low | Off | Off | Off | 10 | 0.6x |
| Mid | On | On | On | 15 | 1.0x |
| High | On | On | On | 20 | 1.3x |

### Scroll Optimization

- Each card wrapped in `RepaintBoundary`
- `ParallaxCardWrapper` uses `AnimatedBuilder` on scroll controller
- `ReorderableListView.builder` for virtualized upcoming list

### Precomputed Display Values

Countdown values (daysRemaining, formattedCountdown, isToday) are cached and recomputed at:

- App open (initial load)
- Midnight (scheduled timer)
- App resume (lifecycle observer)

Values are never recomputed during scroll or widget rebuild.
