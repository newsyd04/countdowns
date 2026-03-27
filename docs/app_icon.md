# Countdowns — App Icon Strategy

> Defines the icon concept, selected direction, and asset requirements for production.

---

## Icon Directions Explored

### Direction A — Calendar Tile

- Rounded square (iOS icon shape) with a bold date number
- Top strip in accent blue (#007AFF) resembling a calendar header
- Large "31" or abstract date numeral centered
- Clean white background
- **Feels**: professional, familiar, iOS-native

**Pros**: Instantly recognizable as a date/calendar app.
**Cons**: Generic — blends in with Apple Calendar and dozens of similar apps. Does not communicate the countdown concept or the app's vibrant personality.

---

### Direction B — Countdown Ring

- Circular progress ring (like a timer) partially filled
- Bold number in the center
- Accent blue ring on white/light background
- **Feels**: dynamic, modern, purposeful

**Pros**: Communicates progress and time remaining. Clean and minimal.
**Cons**: Reads more like a fitness or timer app. Thin ring details can disappear at small icon sizes (29pt, 40pt). No color connection to the app's card palette.

---

### Direction C — Stacked Days (Recommended)

- Rounded square with a large bold number "7" (or abstract numeral)
- Subtle gradient from the card color palette: Coral (#FF6B6B) to Tangerine (#FF9500)
- White text on vibrant background (matches countdown card design language)
- Small subtle sparkle or celebration accent in the upper-right area
- **Feels**: vibrant, premium, connected to the app's visual identity

**Pros**: Distinctive on the home screen. Gradient is eye-catching without being garish. White-on-color mirrors the card motif. Simple bold number reads clearly at every size.
**Cons**: None significant — this direction aligns with the app's identity at every level.

---

## Selected Direction: C — Stacked Days

### Rationale

1. **Matches the card-based visual language.** The app's core UI element is a vibrant colored card with white text. The icon should feel like a natural extension of that design.
2. **Vibrant gradient is distinctive.** The coral-to-tangerine gradient stands out on both light and dark home screens without clashing.
3. **White-on-color is the app's core design motif.** Every countdown card uses white text on a bold background. The icon reinforces this immediately.
4. **Works well at all sizes.** A single bold number has no fine details to lose at 29pt or 40pt. The gradient reads as a warm, inviting color even when tiny.
5. **Celebration sparkle adds personality.** A subtle accent keeps the icon from feeling like a plain colored square, hinting at the joy of counting down to something exciting.

---

## Icon Specification

### Shape

- iOS standard superellipse (continuous corner radius)
- The icon canvas is a full square; iOS applies the mask automatically

### Colors

| Element | Value |
|---------|-------|
| Background gradient start | Coral `#FF6B6B` (top-left) |
| Background gradient end | Tangerine `#FF9500` (bottom-right) |
| Gradient angle | 135 degrees (top-left to bottom-right) |
| Number text | White `#FFFFFF` |
| Sparkle accent | White `#FFFFFF` at 60% opacity |

### Typography

- Number: "7" (or chosen numeral)
- Weight: Bold (800+)
- Size: Approximately 55% of icon height
- Position: Optically centered (slightly above mathematical center)
- Font: SF Pro Display Bold or a geometric sans-serif with similar proportions

### Sparkle Accent

- 4-point star shape, small (roughly 8-10% of icon width)
- Positioned upper-right quadrant, offset from the number
- White at 60% opacity — visible but not competing with the number
- Optional: a second smaller sparkle nearby for depth

---

## Asset Requirements

### iOS

| Asset | Size | Format | Notes |
|-------|------|--------|-------|
| Master icon | 1024x1024 | PNG (no alpha) | Required for App Store. Xcode auto-generates all other sizes. |
| No rounded corners | — | — | iOS applies the superellipse mask. Export as a full square. |

Xcode generates the following from the master:
- 20pt, 29pt, 40pt, 60pt, 76pt, 83.5pt at 1x/2x/3x as needed
- 1024pt for App Store

### Android (Adaptive Icon)

| Asset | Size | Format | Notes |
|-------|------|--------|-------|
| Foreground | 108x108 dp (432x432 px at xxxhdpi) | PNG with transparency | Content must fit within the 66dp (264px) safe zone centered in the 108dp canvas. |
| Background | 108x108 dp | Color or PNG | Use the coral-to-tangerine gradient as a background layer. |

Android adaptive icons allow the OS to apply various masks (circle, squircle, rounded square). The safe zone ensures the number is never clipped.

### Web (PWA)

| Asset | Size | Format | Notes |
|-------|------|--------|-------|
| Standard icon | 192x192 | PNG | Referenced in `manifest.json` |
| Large icon | 512x512 | PNG | Referenced in `manifest.json` |
| Maskable 192 | 192x192 | PNG | Safe zone padding applied; `purpose: maskable` |
| Maskable 512 | 512x512 | PNG | Safe zone padding applied; `purpose: maskable` |
| Favicon | 32x32 | PNG or ICO | Browser tab icon |
| Apple touch icon | 180x180 | PNG | iOS Safari home screen |

### macOS

| Asset | Size | Format | Notes |
|-------|------|--------|-------|
| Master icon | 1024x1024 | PNG | macOS icons use a rounded rectangle with a slight drop shadow and tilt. Design tool should export with macOS-specific template. |

---

## Design Tool Workflow

1. **Create in Figma or Sketch** using the spec above
2. Export the 1024x1024 master PNG (no corners, no alpha for iOS)
3. Use the master to generate all platform variants:
   - iOS: Drop into Xcode asset catalog as `AppIcon`
   - Android: Split into foreground + background layers for `ic_launcher`
   - Web: Resize and export with appropriate padding for maskable variants
4. Validate at small sizes — render at 29pt and 40pt to confirm the number is legible and the gradient reads as a warm color
5. Test on both light and dark wallpapers to ensure contrast

---

## File Placement

```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
  icon-1024.png              (master)
  Contents.json              (Xcode-managed)

android/app/src/main/res/
  mipmap-xxxhdpi/
    ic_launcher_foreground.png
    ic_launcher_background.png
  mipmap-anydpi-v26/
    ic_launcher.xml          (adaptive icon definition)

web/
  icons/
    icon-192.png
    icon-512.png
    icon-192-maskable.png
    icon-512-maskable.png
    favicon.png
```
