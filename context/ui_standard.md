# Mobile UI Standard - Shop App

This document defines the UI/UX standards for the shop mobile application to ensure a consistent, premium, and cohesive user experience across all screens and components.

## 1. Design Philosophy
- **Modern & Playful**: Use vibrant colors and clean typography.
- **Depth & Dimension**: Incorporate 3D assets, subtle shadows, and layered elements.
- **High Contrast**: Ensure clear readability with distinct color separations.
- **Generous Spacing**: Avoid clutter; use whitespace to focus user attention.

## 2. Color Palette

### 2.1 Core Colors
| Color Name | Hex Code | Usage |
| :--- | :--- | :--- |
| **Primary Indigo** | `#5F67F1` | Primary background, active states, key accents. |
| **Pure White** | `#FFFFFF` | Background for light screens, text on dark backgrounds. |
| **Deep Onyx** | `#1A1A1A` | Secondary buttons, primary text on light backgrounds. |
| **Soft Grey** | `#F5F5F5` | Input backgrounds, inactive states. |

### 2.2 Brand/Social Colors
| Brand | Hex Code | Component |
| :--- | :--- | :--- |
| **Google Red** | `#F28B82` | Google Auth Button |
| **Facebook Blue** | `#1877F2` | Facebook Auth Button |
| **Apple Black** | `#2E2E2E` | Apple Auth Button |
| **Email Indigo** | `#8E99F3` | Email Auth Button |

---

## 3. Typography (using ScreenUtil)

- **Primary Font**: `Outfit` (Google Fonts).
- **Scale**:
    - **H1 (Header)**: `32.sp`, Bold, Line-height: 1.2
    - **H2 (Title)**: `24.sp`, Semi-Bold, Line-height: 1.3
    - **Body (Primary)**: `16.sp`, Regular/Medium, Line-height: 1.5
    - **Body (Secondary)**: `14.sp`, Regular, Line-height: 1.5, Muted Opacity (0.8)
    - **Caption**: `12.sp`, Regular, Line-height: 1.4

---

## 4. Components (using ScreenUtil)

### 4.1 Buttons
- **Border Radius**: `16.r` (Highly rounded/Pill-shaped).
- **Height**: Standardized at `56.h`.
- **Primary Action**: White text on Indigo or Indigo text on White.
- **Social Buttons**: Brand color background with centered icon + text ("with [Brand] Account").
- **Secondary Action**: White text on Deep Onyx background.

### 4.2 Cards & Containers
- **Border Radius**: `32.r` for main screen containers; `16.r` for nested cards.
- **Shadows**:
    - `Light`: `box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05)`
    - `Medium`: `box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1)`

### 4.3 Illustrations & Media
- **Style**: Use 3D claymorphism or high-quality vector illustrations with soft gradients.
- **Container**: Illustrations should be centered and occupy ~30-40% of the screen height.

### 4.4 Page Indicators (Dots)
- **Active State**: Pure White, full opacity.
- **Inactive State**: Pure White, 30% opacity.
- **Spacing**: `8.w` between dots.

---

## 5. Layout Standards (using ScreenUtil)
- **Padding**:
    - Screen Horizontal Padding: `24.w`
    - Screen Vertical Padding: `40.h` (respecting safe areas)
- **Alignment**:
    - Text-heavy screens: Centered or Left-aligned based on content type.
    - Onboarding/Auth: Center-aligned content.

---

## 6. Iconography
- **Style**: Line icons or filled icons with rounded caps.
- **Size**:
    - Small: `18.w` (Button icons)
    - Medium: `24.w` (Navigation/Action icons)
    - Large: `48.w+` (Hero icons)

---

## 7. Responsive Utility
Every dimension, margin, padding, radius, and font size MUST be followed by the appropriate `flutter_screenutil` extension:
- Width/Horizontal spacing: `.w`
- Height/Vertical spacing: `.h`
- Font size: `.sp`
- Radius: `.r`
