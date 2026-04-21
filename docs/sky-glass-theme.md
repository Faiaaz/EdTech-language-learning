# EZ Trainz — Sky, Cloud & Glassmorphism Theme

Reference for the login / sign-up sky background and frosted-glass UI. Source: `lib/screens/login_screen.dart`, `lib/screens/sign_up_screen.dart`, `lib/widgets/labeled_field.dart`.

---

## 1. Sky & cloud background

### Color tokens

| Role | Hex | Flutter |
|------|-----|---------|
| Sky fill (scaffold + gradient end) | `#B8E4F8` | `Color(0xFFB8E4F8)` |
| Gradient start (fade over GIF) | `#B8E4F8` at **0% opacity** | `Color(0x00B8E4F8)` |

### Assets & layout

- **Clouds / sky motion:** `assets/images/login_sky_bg.gif`
- **Placement:** Top **~48%** of screen height, full width, `BoxFit.cover`, `alignment: Alignment.topCenter`, `gaplessPlayback: true` (GIF).
- **Blend strip:** `Positioned` from `top: screenH * 0.32`, `height: screenH * 0.22`, with a vertical `LinearGradient` from transparent sky blue to solid `#B8E4F8` so the GIF blends into the lower sky area.

### Flutter example (stack)

```dart
import 'dart:ui';

// ...

final screenH = MediaQuery.of(context).size.height;

return Scaffold(
  backgroundColor: const Color(0xFFB8E4F8),
  body: Stack(
    children: [
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: screenH * 0.48,
        child: Image.asset(
          'assets/images/login_sky_bg.gif',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          gaplessPlayback: true,
        ),
      ),
      Positioned(
        top: screenH * 0.32,
        left: 0,
        right: 0,
        height: screenH * 0.22,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x00B8E4F8),
                Color(0xFFB8E4F8),
              ],
            ),
          ),
        ),
      ),
      // ... content on top
    ],
  ),
);
```

---

## 2. Glassmorphism (main card)

### Parameters

| Element | Value |
|---------|--------|
| Blur | `ImageFilter.blur(sigmaX: 18, sigmaY: 18)` |
| Fill | White at **42%** opacity — `Colors.white.withValues(alpha: 0.42)` |
| Border | White at **65%** opacity, **1.5** px |
| Corner radius | **28** |
| Clipping | `ClipRRect(borderRadius: BorderRadius.circular(28))` wrapping `BackdropFilter` |

**Import:** `dart:ui` for `ImageFilter`.

### Flutter example

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(28),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.42),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.65),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: /* ... */,
    ),
  ),
)
```

---

## 3. Accent colors (login card)

Used alongside the glass panel on the login flow:

| Name | Hex | Flutter |
|------|-----|---------|
| Cyan accent | `#00AEEF` | `Color(0xFF00AEEF)` |
| EZ blue | `#1E88E5` | `Color(0xFF1E88E5)` |
| Yellow | `#FFE000` | `Color(0xFFFFE000)` |
| Soft field border | `#B3DFFA` | `Color(0xFFB3DFFA)` |

---

## 4. Glass-style form fields (`LabeledField` with `glassStyle: true`)

Defined in `lib/widgets/labeled_field.dart`.

| Token | Hex | Notes |
|-------|-----|--------|
| Label | `#0090D4` | |
| Field text | `#1A4F8C` | |
| Field border | `#B3DFFA` | |
| Field background | — | `Colors.white.withValues(alpha: 0.55)` |
| Error text / border | `#FF2D2D` | When `errorText` is set |

---

## 5. Web / CSS approximation

- **Sky blend:** `linear-gradient(to bottom, rgba(184, 228, 248, 0), #b8e4f8)`
- **Glass panel:**  
  `backdrop-filter: blur(18px);`  
  `background: rgba(255, 255, 255, 0.42);`  
  `border: 1.5px solid rgba(255, 255, 255, 0.65);`  
  `border-radius: 28px;`

*(Exact appearance may differ slightly from Flutter due to browser rendering and stacking context.)*

---

## 6. Related screens

- `lib/screens/login_screen.dart` — full login layout and `_buildGlassCard()`
- `lib/screens/sign_up_screen.dart` — same sky asset + gradient + `_sky` constant `Color(0xFFB8E4F8)`
