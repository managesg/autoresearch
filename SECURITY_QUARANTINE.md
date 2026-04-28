# Security Quarantine

Last local audit: 2026-04-28.

## Quarantined Package Roots

- `feynman/website`
  - Residual: moderate Astro XSS advisory.
  - Status: fix requires Astro 6.x breaking upgrade.
  - Recommendation: do not publish the website from this checkout until Astro is upgraded and tested.

- `unsloth/studio/frontend`
  - Residual: moderate Next/PostCSS and Streamdown/Mermaid/uuid advisories.
  - Status: non-breaking npm audit fix could not clear all advisories.
  - Recommendation: local-only use; do not expose the Studio frontend to untrusted users until dependencies are upgraded.
