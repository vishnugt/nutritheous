# Nutritheous Icon Design Guide

## Design Concept

Create a simple, memorable icon that represents nutrition tracking and food analysis.

### Suggested Design Elements

**Primary Option:**
- 🍽️ Fork + 🥗 Healthy food item
- Color: Green (health) + Orange (energy)
- Style: Flat, modern, minimal

**Alternative Options:**
1. Camera viewfinder + food/meal
2. Plate with macro rings (protein/carbs/fat circles)
3. "N" letter mark with leaf or food element
4. Smart device scanning food

## Color Palette Suggestions

### Option 1: Fresh & Healthy
- Primary: `#4CAF50` (Green)
- Secondary: `#FF9800` (Orange)
- Background: `#FFFFFF` (White)

### Option 2: Tech & Smart
- Primary: `#2196F3` (Blue)
- Secondary: `#00BCD4` (Cyan)
- Background: `#FFFFFF` (White)

### Option 3: Premium & Modern
- Primary: `#6200EE` (Purple)
- Secondary: `#03DAC6` (Teal)
- Background: `#FFFFFF` (White)

## Technical Requirements

### Source File
- **Format:** PNG (with transparent background)
- **Size:** 1024x1024px minimum
- **Color Space:** sRGB
- **Bit Depth:** 24-bit or 32-bit

### Design Rules
✅ **DO:**
- Keep it simple and recognizable
- Use bold, clear shapes
- Ensure it works at 20x20px (smallest size)
- Use high contrast
- Keep important content in center 80%
- Test on light and dark backgrounds

❌ **DON'T:**
- Use thin lines (< 2px)
- Include text or words
- Use photos (use illustrations/vectors)
- Make it too detailed or complex
- Use gradients that don't scale well
- Copy other apps' designs

## Android Adaptive Icon

For best Android experience, create TWO images:

### 1. Foreground (icon_foreground.png)
- Size: 432x432px on 1024x1024px transparent canvas
- Contains: Your main icon/logo
- Safe zone: Keep within center 264x264px

### 2. Background (icon_background.png or solid color)
- Size: 1024x1024px
- Contains: Solid color or simple pattern
- No important content (will be masked)

## Quick Start with Design Tools

### Figma/Sketch Template
```
Artboard: 1024x1024px
Grid: 64px
Safe margin: 128px from edges

Layers:
└─ Icon Content (centered)
   ├─ Background shape
   ├─ Primary element
   └─ Accent element (optional)
```

### Export Settings
- Format: PNG
- Scale: 1x (1024x1024px)
- Color profile: sRGB
- Compression: None (script will optimize)

## Example Icon Structure

```
┌─────────────────────────────┐
│                             │ ← 128px margin
│    ┌─────────────────┐     │
│    │                 │     │
│    │   [Fork Icon]   │     │ ← Your main icon
│    │   + Leaf/Food   │     │
│    │                 │     │
│    └─────────────────┘     │
│                             │
└─────────────────────────────┘
     768x768px content area
```

## Testing Your Icon

After generating:
1. View at different sizes (16px, 32px, 64px, 128px, 512px)
2. Test on light background
3. Test on dark background
4. Check on actual device
5. Compare with other nutrition apps

## Need Design Help?

### Hire a Designer
- Fiverr (budget-friendly)
- Upwork (professional)
- 99designs (contest-based)

### DIY Tools
- Canva (templates)
- Figma (free, professional)
- Adobe Express (simple)

### Icon Generators
- App Icon Generator (appicon.co)
- Icon Kitchen (icon.kitchen)

## Current Nutritheous Brand

Match the login screen style:
- Primary color: Theme-based (likely blue)
- Icon: Currently uses `Icons.restaurant_menu`
- Style: Material Design, clean, modern

Suggested: Create a custom version of a plate/utensils with "AI" or tech element to emphasize the smart nutrition tracking aspect.
