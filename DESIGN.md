---
name: Qadaa Prayer Tracker
description: A devotional tool for tracking missed prayers with dignity and ease
colors:
  sacred-green: "#064E3B"
  on-sacred-green: "#FCFCF5"
  sacred-green-container: "#064E3B"
  on-sacred-green-container: "#80BEA6"
  sacred-green-fixed: "#B0F0D6"
  sacred-green-fixed-dim: "#95D3BA"
  trust-blue: "#006591"
  on-trust-blue: "#FCFCF5"
  trust-blue-container: "#E5F6FF"
  on-trust-blue-container: "#004666"
  dark-slate: "#273034"
  dark-slate-container: "#DEE4E8"
  error-red: "#BA1A1A"
  error-container: "#FFDAD6"
  surface-bright: "#F7FAF4"
  surface-dim: "#D2E1D0"
  surface-container-low: "#EEF3E9"
  surface-container: "#E5ECE0"
  surface-container-high: "#DCE5D6"
  surface-container-highest: "#D2DECC"
  on-surface: "#141C12"
  on-surface-variant: "#3E4839"
  outline: "#6F7A69"
  outline-variant: "#BEC8B7"
  inverse-surface: "#213145"
  inverse-primary: "#95D3BA"
  dark-surface: "#0F1A14"
  dark-on-surface: "#E0E6DC"
  dark-on-surface-variant: "#BEC8B7"
  dark-surface-container-low: "#1A261E"
  dark-surface-container: "#1F2C23"
  dark-surface-container-high: "#29382E"
  dark-surface-container-highest: "#34443A"
  dark-outline: "#88947F"
  dark-outline-variant: "#3E4839"
  dark-primary: "#80BEA6"
  chart-fajr: "#D4A843"
  chart-dhuhr: "#5B8C5A"
  chart-asr: "#C4674B"
  chart-maghrib: "#8B6B4D"
  chart-isha: "#4A6FA5"
  chart-fajr-dark: "#E8C76A"
  chart-dhuhr-dark: "#7EB07D"
  chart-asr-dark: "#D4896F"
  chart-maghrib-dark: "#A68B6A"
  chart-isha-dark: "#6E93C9"
typography:
  display:
    fontFamily: "Plus Jakarta Sans"
    fontSize: "26px"
    fontWeight: 700
    letterSpacing: "-0.5px"
  headline:
    fontFamily: "Plus Jakarta Sans"
    fontSize: "22px"
    fontWeight: 700
  title:
    fontFamily: "Plus Jakarta Sans"
    fontSize: "15px"
    fontWeight: 600
  body:
    fontFamily: "Plus Jakarta Sans"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "Plus Jakarta Sans"
    fontSize: "11px"
    fontWeight: 500
    letterSpacing: "0.3px"
rounded:
  sm: "6px"
  md: "10px"
  lg: "16px"
  xl: "24px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "24px"
  xxl: "32px"
  xxxl: "48px"
  xxxxl: "64px"
components:
  button-primary:
    backgroundColor: "{colors.sacred-green}"
    textColor: "{colors.on-sacred-green}"
    rounded: "{rounded.sm}"
    padding: "24px 16px"
  button-primary-dark:
    backgroundColor: "{colors.dark-primary}"
    textColor: "{colors.dark-surface}"
    rounded: "{rounded.sm}"
    padding: "24px 16px"
  text-button:
    textColor: "{colors.sacred-green}"
  text-button-dark:
    textColor: "{colors.dark-primary}"
  card:
    backgroundColor: "{colors.surface-container-low}"
    rounded: "{rounded.md}"
  card-dark:
    backgroundColor: "{colors.dark-surface-container-low}"
    rounded: "{rounded.md}"
  input:
    backgroundColor: "{colors.surface-container-low}"
    rounded: "{rounded.sm}"
    borderColor: "{colors.outline-variant}"
  input-dark:
    backgroundColor: "{colors.dark-surface-container}"
    rounded: "{rounded.sm}"
    borderColor: "{colors.dark-outline-variant}"
  navigation-bar-label-selected:
    textColor: "{colors.sacred-green}"
  navigation-bar-label-selected-dark:
    textColor: "{colors.dark-primary}"
  navigation-bar-icon-selected:
    textColor: "{colors.sacred-green}"
  navigation-bar-icon-selected-dark:
    textColor: "{colors.dark-primary}"
---

# Design System: Qadaa Prayer Tracker

## 1. Overview

**Creative North Star: "The Devotional Garden"**

The app feels like a quiet garden at dawn — calm, purposeful, rooted in tradition. Every interaction is a moment of stillness between the user and their practice. The deep green of Sacred Green anchors the system like mature foliage; warm off-white surfaces suggest natural light filtering through leaves. Nothing competes for attention — the interface recedes so the act of logging a prayer remains central.

This is a spiritual tool, not a product dashboard. The design rejects gamified mechanics (streaks-as-pressure, badges, leaderboards) as well as synthetic dark-neon-cyber aesthetics. Warmth, dignity, and devotional clarity govern every decision.

**Key Characteristics:**
- Tonal layering replaces shadows — depth comes from surface containers, not drop shadows
- One typeface (Plus Jakarta Sans) across all weights — clean, readable, quietly elegant
- Color is purposeful and restrained — Sacred Green occupies 30% or less of any screen; neutrals carry the remainder
- Motion is minimal and purposeful — state changes and feedback only, no choreography
- Sacred geometry expressed through clean rounded corners and balanced spacing, not decorative patterns

## 2. Colors

The palette centers on a deep, warm sacred green that honors Islamic design tradition. Neutrals carry a subtle green undertone (chroma ≈ 0.005) to unify the system. Dark mode inverts the tonal stack while preserving the green accent.

### Primary
- **Sacred Green** (#064E3B): Primary actions, selected navigation states, filled icons. The anchor of the system — used sparingly for emphasis, never for backgrounds.
- **On Sacred Green** (#FCFCF5): Text and icons on Sacred Green surfaces.
- **On Sacred Green Container / Dark Primary** (#80BEA6): Primary text and icons on dark surfaces — the light mint-green counterpart that maintains WCAG AA contrast in dark mode.
- **Sacred Green Fixed** (#B0F0D6), **Fixed Dim** (#95D3BA): Light green accents for chart fills and secondary highlights.

### Secondary
- **Trust Blue** (#006591): Secondary actions, links, informational accents. Provides cool balance to the warm green.
- **Trust Blue Container** (#E5F6FF), **On Container** (#004666): Light/dark pair for secondary surface use.

### Tertiary
- **Dark Slate** (#273034): Tertiary text and muted UI elements. A near-black with a cool blue cast.
- **Dark Slate Container** (#DEE4E8): Light tertiary surface for tag-like elements.

### Neutral
- **Surface Bright** (#F7FAF4): Primary background — light, warm, with a barely perceptible green tint.
- **Surface Dim** (#D2E1D0): Inverse background base.
- **Surface Container Low / Container / High / Highest** (#EEF3E9 → #D2DECC): Tonal depth stack. Lightest is card background, darkest is highest-elevation container.
- **On Surface** (#141C12): Primary text — a very dark green-black.
- **On Surface Variant** (#3E4839): Secondary text, muted labels.
- **Outline** (#6F7A69), **Outline Variant** (#BEC8B7): Borders and dividers.

### Dark Mode Neutrals
- **Dark Surface** (#0F1A14): Dark mode background — a very dark green-black.
- **Dark On Surface** (#E0E6DC): Primary text in dark mode.
- **Dark On Surface Variant** (#BEC8B7): Secondary text in dark mode.
- **Dark Surface Container Low / Container / High / Highest** (#1A261E → #34443A): Tonal depth stack for dark mode.

### Chart Colors (Light / Dark)
- **Fajr** (#D4A843 / #E8C76A), **Dhuhr** (#5B8C5A / #7EB07D), **Asr** (#C4674B / #D4896F), **Maghrib** (#8B6B4D / #A68B6A), **Isha** (#4A6FA5 / #6E93C9): Distinct warm and cool hues for each prayer time. Dark variants lightened for readability on dark backgrounds.

### Named Rules
**The Garden Tone Rule.** Every neutral carries a trace of green (chroma ≈ 0.005). Pure gray, cool blue-gray, and warm beige are all forbidden — the system's warmth comes from this consistent undertone.

**The Rarity Rule.** Sacred Green occupies 30% or less of any screen. Its infrequency gives it weight. Buttons, selected nav items, and small icon fills are its natural home; large background swaths are not.

## 3. Typography

**Display / Body / Label Font:** Plus Jakarta Sans (single family)

**Character:** Clean, humanist, quietly elegant. A single sans-serif family carries the full hierarchy through weight and size contrast rather than font switching. The rounded terminals and open apertures of Plus Jakarta Sans keep the interface approachable without sacrificing precision.

### Hierarchy
- **Display** (700, 26px, -0.5px letter-spacing): Stat card values — short, scannable numbers with tight letter-spacing for impact.
- **Headline** (700, 22px): Screen titles and section headings.
- **Title** (600, 15px): Card titles, list item names, button labels.
- **Body** (400, 14px, 1.5 line-height): Primary reading text. Line length capped at 65–75ch.
- **Label** (500, 11px, 0.3px letter-spacing): Navigation bar labels, stat card labels, small metadata.

### Named Rules
**The One Family Rule.** No font switching. All hierarchy is expressed through weight (400 / 500 / 600 / 700) and size, not typeface changes.

## 4. Elevation

**Flat by default. Depth through tone, not shadow.**

The system uses zero drop shadows. Elevation is communicated exclusively through the tonal container stack: surfaceContainerLow → surfaceContainer → surfaceContainerHigh → surfaceContainerHighest. Each step is slightly darker (in light mode) or lighter (in dark mode), creating clear visual hierarchy without any shadow vocabulary.

Cards at rest sit at surfaceContainerLow — they need no shadow because they have their own surface color. Interactive elements (buttons, inputs) sit on their own colored surfaces.

## 5. Components

### Buttons
- **Shape:** Gently rounded corners (6px radius).
- **Primary:** Sacred Green background, On Sacred Green text, 24px horizontal / 12px vertical padding.
- **Dark mode:** Dark Primary (#80BEA6) background, Dark Surface (#0F1A14) text. Inverted to maintain contrast.
- **Hover / Focus:** No hover color shift (mobile-native). Focus border treatment matches inputs — 1.5px darker outline.
- **Text Button:** Matching color (Sacred Green light / Dark Primary dark), no background, 600 weight.

### Cards
- **Corner Style:** Rounded (10px radius).
- **Background:** Surface Container Low (light) / Dark Surface Container Low (dark).
- **Shadow Strategy:** None. Depth from tonal layer.
- **Border:** None.
- **Internal Padding:** 16px.
- **Clip Behavior:** Anti-alias applied for corner clipping.

### Inputs / Text Fields
- **Style:** Filled background (Surface Container Low light / Dark Surface Container dark), subtle outline border (Outline Variant), 6px radius.
- **Focus:** Border shifts to Sacred Green (light) or Dark Primary (dark), 1.5px width.
- **Error:** Border shifts to Error Red (#BA1A1A), with inline error text below.
- **Label:** On Surface Variant text at 14px.

### Navigation Bar
- **Style:** Bottom navigation bar with transparent surface background.
- **Unselected:** On Surface Variant text and icons (22px).
- **Selected:** Sacred Green (light) or Dark Primary (dark) text and icons, with a 12% (light) / 20% (dark) opacity indicator pill.
- **Indicator Shape:** 6px radius pill under the selected icon.
- **Label Text:** 11px, 0.3px letter-spacing, 700 weight (selected) / 500 weight (unselected).

### StatCard
- **Purpose:** Display a single prayer statistic (total count, streak, etc.) in a metric card.
- **Icon Container:** 34x34px, filled with the prayer color, 6px radius, white icon (18px).
- **Value:** 26px, 700 weight, prayer-colored text, -0.5px letter-spacing.
- **Sub / Label:** Secondary text in On Surface Variant and Outline respectively.

### PressScale
- **Behavior:** Wraps any tappable element. On press, scales child to 0.97 over 150ms using ease-out cubic bezier (0.23, 1, 0.32, 1). Subtle tactile feedback without bounce.

### ToggleTile
- **Purpose:** The signature qadaa prayer toggle — core devotional interaction.
- **Layout:** Card with InkWell. Row of animated check circle + prayer name + prayer time.
- **Check Circle:** 28px circle. Unselected: empty with Outline border. Selected: filled Sacred Green with white checkmark. Animated at 150ms with ease-out curve.
- **Text:** Completed prayers show line-through decoration and On Surface Variant color.

## 6. Do's and Don'ts

### Do:
- **Do** use Sacred Green on 30% or less of any screen. Its rarity is its power.
- **Do** use the tonal container stack for elevation instead of shadows.
- **Do** use Plus Jakarta Sans for all text — one family, all weights.
- **Do** keep motion restrained — state changes and feedback only, no choreographed entrances.
- **Do** ensure every neutral carries a green trace (the Garden Tone Rule).
- **Do** use flat cards with container backgrounds rather than bordered or shadowed cards.

### Don't:
- **Don't** use gamification patterns — no badges, achievements, leaderboards, or streaks-as-pressure. The app is devotional, not competitive.
- **Don't** use dark mode with purple gradients, neon accents, or glassmorphism. Stay warm and natural.
- **Don't** use bounce or elastic easing (easeOutBack, spring animations). Use the custom ease-out cubic bezier.
- **Don't** use gradient text for any purpose. Solid color only.
- **Don't** use side-stripe borders (border-left > 1px as accent). Use full borders, background fills, or nothing.
- **Don't** use nested cards. Cards are the lazy answer.
- **Don't** add decorative patterns, geometric overlays, or Islamic pattern motifs as background elements. The interface stays clean and undistracting.
- **Don't** use em dashes in copy. Use commas, colons, semicolons, periods, or parentheses.
- **Don't** use material dynamic color theming (ColorScheme.fromSeed). The palette is hand-tuned and intentional.
