---
name: Zenith EdTech
colors:
  surface: '#0b1326'
  surface-dim: '#0b1326'
  surface-bright: '#31394d'
  surface-container-lowest: '#060e20'
  surface-container-low: '#131b2e'
  surface-container: '#171f33'
  surface-container-high: '#222a3d'
  surface-container-highest: '#2d3449'
  on-surface: '#dae2fd'
  on-surface-variant: '#bccbb9'
  inverse-surface: '#dae2fd'
  inverse-on-surface: '#283044'
  outline: '#869585'
  outline-variant: '#3d4a3d'
  surface-tint: '#4ae176'
  primary: '#4be277'
  on-primary: '#003915'
  primary-container: '#22c55e'
  on-primary-container: '#004b1e'
  inverse-primary: '#006e2f'
  secondary: '#adc6ff'
  on-secondary: '#002e6a'
  secondary-container: '#0566d9'
  on-secondary-container: '#e6ecff'
  tertiary: '#ffba61'
  on-tertiary: '#472a00'
  tertiary-container: '#ef9900'
  on-tertiary-container: '#5c3800'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#6bff8f'
  primary-fixed-dim: '#4ae176'
  on-primary-fixed: '#002109'
  on-primary-fixed-variant: '#005321'
  secondary-fixed: '#d8e2ff'
  secondary-fixed-dim: '#adc6ff'
  on-secondary-fixed: '#001a42'
  on-secondary-fixed-variant: '#004395'
  tertiary-fixed: '#ffddb8'
  tertiary-fixed-dim: '#ffb95f'
  on-tertiary-fixed: '#2a1700'
  on-tertiary-fixed-variant: '#653e00'
  background: '#0b1326'
  on-background: '#dae2fd'
  surface-variant: '#2d3449'
typography:
  headline-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Be Vietnam Pro
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Noto Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Noto Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  japanese-display:
    fontFamily: Noto Sans
    fontSize: 28px
    fontWeight: '500'
    lineHeight: 36px
  bengali-display:
    fontFamily: Noto Sans
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 32px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-padding: 24px
  gutter: 16px
  stack-sm: 12px
  stack-md: 20px
---

## Brand & Style
The brand personality is authoritative yet encouraging, designed for learners who seek a focused, "Pro" environment for mastering complex scripts. The design system utilizes a **Modern Corporate** aesthetic with **Glassmorphic** accents to create a sense of depth and precision. 

The emotional response should be one of "effortless focus"—reducing cognitive load through high-contrast legibility and a sophisticated dark environment that minimizes eye strain during long study sessions. The visual mood is premium and cinematic, moving away from "casual gaming" and toward "structured mastery."

## Colors
The palette is rooted in a deep, midnight-navy foundation to provide a "Pro" feel. 
- **Primary (Vibrant Emerald):** Reserved strictly for success states, correct answers, and active progress milestones. It provides a high-energy contrast against the dark background.
- **Secondary (Electric Azure):** Used for primary actions, navigational highlights, and informational badges.
- **Tertiary (Amber):** Used for streak indicators, gold stars, and premium "pro" features.
- **Neutral/Surface:** A range of slate-toned charcoals used to create depth through layering rather than flat black.

## Typography
The system uses a multi-script typographic approach to ensure Bengali and Japanese characters receive equal visual weight and clarity. 
- **Headlines:** Use *Be Vietnam Pro* for a modern, geometric look in titles.
- **Global Body/Scripts:** *Noto Sans* is the workhorse font, selected for its exceptional multi-language support, ensuring that Japanese Kanji/Kana and Bengali glyphs are rendered with consistent stroke weights.
- **Labels:** *Inter* is used for functional UI elements (badges, buttons, micro-copy) due to its high legibility at small scales.

## Layout & Spacing
The design system employs a **Fixed Grid** on desktop (max-width 1200px) and a **Fluid 4-Column Grid** on mobile. 
- **Margins:** A generous 24px side margin on mobile ensures content doesn't feel cramped.
- **Vertical Rhythm:** Built on an 8px baseline. Grouped elements (like a Japanese word and its translation) use a tight 4px or 8px "stack-sm" gap, while distinct sections use a 24px margin to maintain hierarchy.
- **Reflow:** On mobile, progress tracking and score badges stack vertically; on tablet/desktop, they shift to a horizontal top-bar layout.

## Elevation & Depth
Depth is created using **Tonal Layers** and **Glassmorphism**.
- **The Canvas:** Deepest layer (`#020617`).
- **Cards/Containers:** Elevated slightly using `#1E293B` with a subtle 1px border (`#334155`) to define edges without heavy shadows.
- **Modal Overlays:** Use a high-degree backdrop blur (20px) with a semi-transparent surface (`rgba(30, 41, 59, 0.8)`). This keeps the user contextually aware of the lesson behind the modal.
- **Shadows:** Only used on active elements (buttons, modals). Shadows are large, soft, and tinted with the secondary blue color to prevent a "dirty" look.

## Shapes
The shape language is **Rounded (0.5rem base)**. This softens the "technical" feel of the dark theme, making the learning experience feel more approachable and modern.
- **Small Components:** Checkboxes and small tags use 4px (Soft).
- **Primary Buttons & Cards:** Use 8px (Rounded).
- **Modals & Score Badges:** Use 16px (Rounded-LG) to emphasize their status as significant UI containers.

## Components
- **Buttons:** Primary buttons use a solid blue-to-navy gradient with white text. Success buttons (for correct answers) use the vibrant green primary color with a subtle inner glow.
- **Chips/Choice Chips:** Used for Japanese character selection. These feature a ghost-border style in the idle state and a solid-fill border when selected.
- **Progress Tracking:** A sleek, horizontal bar with a gradient fill. The bar background should be a low-opacity version of the secondary color.
- **Score Badges:** Encapsulated units with a "glass" effect—semi-transparent background and a high-contrast icon (e.g., a gold star for scores).
- **Input Fields:** Darker than the card surface, with a focus state that glows slightly using the secondary azure color.
- **Modal Overlays:** Centered, with a high-contrast white or light-grey title to demand immediate attention, contrasting against the dark app environment.