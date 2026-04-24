iPhone Meditation App — Plan

  App Overview

  A nature-sounds meditation app with curated playlists, a 10-minute free trial, and a subscription paywall. Design inspired by Calm/Headspace.

  ---
  Tech Stack

  ┌───────────────┬───────────────────────────────┬────────────────────────────────────────────────────────┐
  │     Layer     │            Choice             │                          Why                           │
  ├───────────────┼───────────────────────────────┼────────────────────────────────────────────────────────┤
  │ Language      │ Swift + SwiftUI               │ Native iOS, best audio/animation support               │
  ├───────────────┼───────────────────────────────┼────────────────────────────────────────────────────────┤
  │ Audio         │ AVFoundation + AVAudioSession │ Seamless looping, background playback, AirPlay         │
  ├───────────────┼───────────────────────────────┼────────────────────────────────────────────────────────┤
  │ Backend       │ None (v1)                     │ StoreKit 2 syncs via Apple ID — no backend needed      │
  ├───────────────┼───────────────────────────────┼────────────────────────────────────────────────────────┤
  │ Subscriptions │ StoreKit 2                    │ Native Apple IAP, syncs across devices via Apple ID    │
  ├───────────────┼───────────────────────────────┼────────────────────────────────────────────────────────┤
  │ Audio Storage │ Cloudflare R2 + CDN           │ No egress fees, fast global streaming                  │
  └───────────────┴───────────────────────────────┴────────────────────────────────────────────────────────┘

  ---
  Audio Storage & Streaming Strategy

  Store on Cloudflare R2, stream via CDN (not bundled in app)

  - Audio files stay small (compressed AAC, ~1MB/min)
  - Users stream on demand — no 500MB app download
  - You can update/add files without an app update
  - Free trial enforcement tracked locally via UserDefaults — 10 minutes lifetime, never resets
  - Subscribers can download tracks for offline playback (stored in app Documents directory)

  File format: AAC 128kbps, seamlessly looped (use Audacity/Logic to trim for gapless looping)

  ---
  App Architecture

  App
  ├── Onboarding (3 screens) ✓
  ├── Home ✓
  │   ├── Featured Playlist ✓
  │   ├── Category Grid (Wind, Fire, Affirmations) ✓
  │   └── "Get Premium" button (visible to non-subscribers) ✓
  ├── Playlist Detail ✓
  │   ├── Scrollable hero + track list (single unified scroll) ✓
  │   ├── "Play All" button — starts full queue from track 1 ✓
  │   └── Per-track download button (subscribers only) ✓
  ├── Player Screen ✓
  │   ├── Breathing circle animation ✓
  │   ├── Now Playing + track name + "X of Y" queue position ✓
  │   ├── Prev / Play-Pause / Next controls ✓
  │   ├── Loop toggle (loops playlist or stops at end) ✓
  │   └── Trial progress bar (non-subscribers) ✓
  ├── Paywall Screen ✓
  │   └── Triggered at 10min lifetime, on locked content tap, or "Get Premium" ✓
  └── Settings / Profile — TODO
      └── Subscription status, manage/cancel link

  ---
  Subscription Model

  - Free tier: 10 cumulative minutes lifetime (tracked locally, never resets)
  - Premium: $4.99/month or $49.99/year (2 months free vs monthly — ~17% off)
  - StoreKit 2 handles everything: purchases, restores, family sharing, cross-device sync via Apple ID
  - No backend needed — entitlement verified on-device via Transaction.currentEntitlements
  - Offline downloads available to subscribers (files stored in app Documents directory)
  - Track premium status is hardcoded in Playlist.swift — update in code to change

  Paywall trigger points:
  1. User hits 10-minute lifetime limit mid-session → soft interrupt with paywall
  2. User taps a "Premium" tagged track
  3. User taps "Get Premium" button on home screen

  ---
  Design Direction (Calm/Headspace inspired)

  - Color palette: Deep navy background, soft cream (#f0efea) text, muted gold accents ✓
  - Typography: Serif headings + rounded sans body (system fonts) ✓
  - Animations: Breathing circle on player screen (3-layer pulse, ~4.5s cycle) ✓
  - Onboarding: 3 screens — icon, title, body copy → gold CTA button ✓
  - No clutter: Player screen is nearly empty — visual, track name, and controls only ✓

  ---
  Development Phases

  Phase 1 — Core ✓ DONE
  - SwiftUI shell, navigation, audio player with AVFoundation
  - 4 playlists (Wind & Sky, Fireside, Taylor Welch Affirmations, Biblical Truth Affirmations), CDN URLs as placeholders
  - 10-minute lifetime trial timer (UserDefaults, survives app restarts)
  - Paywall screen (UI complete, purchase stubbed)
  - Offline download per track (subscribers only)
  - Breathing animation, mini-player, onboarding
  - Queue-based playback: Play All, prev/next, loop toggle
  - Unified scrolling playlist detail (hero scrolls with tracks)

  Phase 2 — StoreKit 2 (next)
  - [ ] Create products in App Store Connect (monthly $4.99 + annual $49.99)
  - [ ] Wire StoreKit 2 purchase flow in PaywallView (replace stub in PaywallView.swift)
  - [ ] Verify entitlement on launch via Transaction.currentEntitlements
  - [ ] Handle subscription expiry / renewal
  - [ ] Wire "Restore Purchases" button in PaywallView (currently a no-op)
  - [ ] Sandbox testing on device

  Phase 3 — Finish & Ship
  - [ ] Sleep timer: implement stop-playback logic in PlayerView (UI already exists)
  - [ ] Settings screen (subscription status, manage/cancel deep link to App Store)
  - [ ] Upload real audio files to Cloudflare R2, replace placeholder CDN URLs in Playlist.swift
  - [ ] Add background audio in Xcode: Signing & Capabilities → Background Modes → Audio
  - [ ] App Store screenshots + submission

  ---
  Key Decisions — Resolved

  1. Offline downloads for premium? → YES, implemented ✓
  2. No backend for v1 → StoreKit 2 + Apple ID handles cross-device sync ✓
  3. Trial model → 10 minutes lifetime (not per-day), local only ✓
  4. Track premium status → hardcoded in Playlist.swift for v1, update in code to change ✓

  Key Decisions — Open

  1. Blending two sounds (rain + fire)? Calm does this — high retention feature, moderate effort
  2. Guided meditations (voice)? Out of scope for v1 but plan the content structure for it
