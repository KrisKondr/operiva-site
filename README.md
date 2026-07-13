# OPERIVA Site

Static OPERIVA landing page.

The page is unpacked into regular static files: `index.html` plus local assets in
`assets/`. No external CDN is required for React, ReactDOM, fonts, or the logo.

The first visit starts with a full-screen interactive Spline robot greeting. The
Spline runtime and `.splinecode` scene are self-hosted in `assets/`, so the intro
does not depend on a CDN at runtime. The intro shows only the interactive robot,
using the same dark background and mint accent palette as the landing page.
Entering the site uses a short opacity transition with no large GPU-heavy scaling.

## Run locally

```powershell
python -m http.server 8027 --bind 127.0.0.1
```

Open:

```text
http://127.0.0.1:8027/
```

Entry file: `index.html`

The separate cases page is available at `cases.html`. Its local fonts, scripts,
and logo are stored under `assets/cases/`.

## Publish and edit from another device

The GitHub Pages workflow in `.github/workflows/pages.yml` publishes the site
automatically after every push to the `main` branch.

To make a quick edit from another device, open the repository on GitHub, select
the required HTML, CSS, or JavaScript file, press the pencil icon, then use
`Commit changes`. GitHub Pages will publish that commit automatically.
