Performance, Accessibility & SEO fixes applied

What I changed (concrete edits)
- index.html
  - Removed `noindex` and added canonical + Open Graph + Twitter meta tags and JSON-LD person structured data.
  - Preconnected & added Google Fonts link in head and removed CSS @import from `style.css`.
  - Preloaded hero image to help Largest Contentful Paint (LCP).
  - Preloaded critical CSS files (`bootstrap.min.css`, `style.css`) and loaded other CSS with media swapping to reduce render-blocking.
  - Deferred all vendor JS and `assets/js/main.js` using `defer` to avoid blocking initial render.
  - Removed duplicate external CDN jQuery include and ensured local `assets/js/vendor/jquery.js` is used.
  - Added meaningful `alt` text to images, `width`/`height` attributes and `loading="lazy"` to non-critical images.
  - Added ARIA roles (`role="banner"`, `role="main"`) and `aria-label` on nav and form inputs; added a "Skip to content" link.
  - Added rel="noopener noreferrer" and target="_blank" to external links where appropriate and accessible hidden labels for social icons.

- assets/css/style.css
  - Removed blocking `@import` for Google Fonts.
  - Removed global `overflow: hidden` rules that prevented normal scrolling.
  - Added `.sr-only` helper for screen-reader-only text.

- assets/css/plugins/feature.css
  - Attempted to ensure icon font uses `font-display: swap` (if present)

- scripts/convert-images.ps1
  - Added a helper PowerShell script to convert images to WebP using `cwebp` (libwebp) to improve image compression.

Next recommended steps (you should run these locally)
1) Optimize images to WebP and update HTML
   - Install libwebp (cwebp) and run: 
     powershell.exe -ExecutionPolicy Bypass -File .\scripts\convert-images.ps1 -SourceDir "assets/images/port" -Quality 80
   - Replace `img` tags with a `<picture>` element to serve WebP with JPG/PNG fallback for browsers that don't support WebP.

2) Run Lighthouse / PageSpeed locally and iterate
   - Use Chrome DevTools Lighthouse (Audits -> Lighthouse) or CLI:
     npm install -g lighthouse
     lighthouse https://your-domain.example --output html --output-path=./lighthouse-report.html --only-categories=performance,accessibility,seo

3) Add caching & compression on server
   - Configure your web server (nginx, Apache, Cloudflare) to serve far-future cache headers for static assets, enable gzip/Brotli compression and set proper content-type and Vary headers.

  Example nginx snippet (add to your server block or an include file):

  ```nginx
  # Cache static assets for 30 days and set proper headers
  location ~* \.(?:css|js|jpg|jpeg|gif|png|svg|webp|ico)$ {
     expires 30d;
     add_header Cache-Control "public, max-age=2592000, immutable";
     access_log off;
  }

  # Serve compressed assets (gzip) and accept precompressed files if present
  gzip on;
  gzip_types text/plain text/css application/javascript application/json image/svg+xml;
  gzip_proxied any;
  gzip_vary on;

  # If you can enable Brotli (recommended), use ngx_brotli and advertise it
  brotli on;
  brotli_types text/plain text/css application/javascript application/json image/svg+xml;
  brotli_comp_level 5;
  ```

4) Further JS improvements
   - Consider loading big libraries (AOS, particles, slick) only on pages/sections that use them (code-splitting) and lazy-init them when the section enters the viewport.
   - Defer animation libraries until after user interaction or after LCP to avoid competition for main thread.

5) Accessibility checks
   - Run automated a11y checks (axe DevTools, Lighthouse) and manually test keyboard navigation, focus order, and color contrast for key text.

Quality gates status (quick triage)
- Build: PASS (no build step for this static site)
- Lint/Typecheck: N/A (CSS has some vendor-only properties warnings but not fatal)
- Tests: N/A

If you'd like, I can:
- Convert images and create WebP versions and update the HTML <picture> tags for you (I can generate changes to HTML referencing .webp files but can't create binary images here).
- Split and inline critical CSS (small effort) and move the rest to async load.
- Add a small automated Lighthouse run script and collect results.

Tell me which of the next steps you'd like me to perform next and I'll do it.