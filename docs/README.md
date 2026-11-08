# Asperito Motion Website

This directory is a fully static, mobile-first GitHub Pages experience for **Asperito**.

- `index.html`: semantic content, live guide selector and screenshot gallery.
- `style.css`: cinematic midnight / champagne-gold visual design, adaptive responsive layouts, scroll transitions, depth, and reduced-motion preferences.
- `app.js`: interactive composition-guide selector, screenshot carousel navigation, accessible state announcements and scroll reveal.
- `screenshots/`: original 17 PNG captures from iPhone Simulator, copied automatically by GitHub Actions.
- `favicon.svg`: minimal framing symbol.

## Live URL

https://prabhuvikas.github.io/FrameGuide/

Publishing is configured in `.github/workflows/asperito-site.yml` and targets the `feat/ios-mvp` development branch. **One-time owner action may be required:** open repository Settings → Pages and set Build and deployment source to **GitHub Actions**. Then rerun the **Asperito Website + Screenshots** workflow. After merging the feature branch, update the workflow trigger and checkout ref to `main`.

## Accessibility and motion

- Semantic landmarks and headings; keyboard-accessible guide buttons and gallery arrows.
- Selected guides report `aria-pressed`; updates announce via `aria-live`.
- `prefers-reduced-motion` disables entrance transitions, floating effects, and smooth scrolling.
- All screenshot images use meaningful alt text; controls have descriptive labels.
- Responsive layout for narrow iPhones, tablets, and desktop.

## Copyright and photo authenticity

The aesthetic takes inspiration from Apple's spacious editorial web design, but does not copy Apple branding, proprietary site code, or interface assets.

All **application screenshots are real screenshots of Asperito's SwiftUI views captured in Simulator**; the scene behind the composition overlays is a *synthetic, deterministic landscape fixture*, not an image captured by iPhone camera hardware. The website clearly states this limitation. Physical device tests and photographs are required before App Store marketing.

## Local preview

From repository root:

```bash
python3 -m http.server 8000 --directory docs
```

Open http://localhost:8000/ in a browser. The page uses standard HTML/CSS/JavaScript without a build step or external JS dependencies. Google Fonts load if online, with system font fallbacks offline.
