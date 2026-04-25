iPhone Meditation App — Plan

  App Overview

  A biblical affirmations and nature-sounds app with curated playlists, a 10-minute free trial, and a subscription paywall. Design inspired by Calm/Headspace.

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

  - CDN base URL: https://pub-d6aadca8714e4a51804dc8762b7f9f6d.r2.dev ✓
  - Audio files converted from WAV → AAC 192kbps stereo ✓
  - Durations hardcoded in Playlist.swift (from ffprobe) ✓
  - Users stream on demand — no large app download
  - You can update/add files without an app update
  - Free trial enforcement tracked locally via UserDefaults — 10 minutes lifetime, never resets
  - Subscribers can download tracks for offline playback (stored in app Documents directory)
  - isLoop flag on Track — loop tracks show "Xm loop", others show m:ss duration ✓

  ---
  Catalog (4 playlists, 87 tracks total)

  1. Affirmations for Confidence + Healing Frequencies — 25 tracks, affirmations category
  2. Biblical Identity Affirmations + Thunderstorms & 528Hz — 30 tracks, rain category
  3. Biblical Identity Affirmations + Ocean Waves & Solfeggio Frequencies — 31 tracks, ocean category
  4. Ocean Waves + Healing Frequencies for Sleep — 1 track (~50 min loop), ocean category

  ---
  App Architecture

  App
  ├── Onboarding (3 screens) ✓
  ├── Home ✓
  │   ├── Featured Playlist ✓
  │   ├── Category Grid ✓
  │   └── "Get Premium" button (visible to non-subscribers) ✓
  ├── Playlist Detail ✓
  │   ├── Scrollable hero + track list (single unified scroll) ✓
  │   ├── "Play All" button — starts full queue from track 1 ✓
  │   └── Per-track download button (subscribers only) ✓
  ├── Player Screen ✓
  │   ├── Now Playing + track name + "X of Y" queue position ✓
  │   ├── Prev / Play-Pause / Next controls ✓
  │   ├── Loop toggle (loops playlist or stops at end) ✓
  │   └── Trial progress bar (non-subscribers) ✓
  ├── Mini Player ✓
  │   └── Shows album artwork ✓
  └── Paywall Screen ✓
      └── Triggered at 10min lifetime, on locked content tap, or "Get Premium" ✓

  ---
  Subscription Model

  - Free tier: 10 cumulative minutes lifetime (tracked locally, never resets)
  - Premium: $4.99/month or $49.99/year (2 months free vs monthly — ~17% off)
  - StoreKit 2 handles everything: purchases, restores, family sharing, cross-device sync via Apple ID
  - No backend needed — entitlement verified on-device via Transaction.currentEntitlements
  - Offline downloads available to subscribers (files stored in app Documents directory)
  - Track premium status is hardcoded in Playlist.swift — update in code to change
  - First 2-3 tracks per playlist are free; remaining tracks require subscription

  Paywall trigger points:
  1. User hits 10-minute lifetime limit mid-session → soft interrupt with paywall
  2. User taps a locked track
  3. User taps "Get Premium" button on home screen

  ---
  Design Direction (Calm/Headspace inspired)

  - Color palette: Deep gray background, soft cream (#f0efea) text, muted gold accents ✓
  - Typography: Serif headings + rounded sans body (system fonts) ✓
  - Onboarding: 3 screens — icon, title, body copy → gold CTA button ✓
  - No clutter: Player screen is nearly empty — visual, track name, and controls only ✓
  - Album cards show artwork only — no premium badge on albums, lock icon on individual tracks only ✓

  ---
  Development Phases

  Phase 1 — Core ✓ DONE
  - [x] SwiftUI shell, navigation, audio player with AVFoundation
  - [x] 4 playlists, CDN URLs as placeholders
  - [x] 10-minute lifetime trial timer (UserDefaults, survives app restarts)
  - [x] Paywall screen (UI complete, purchase stubbed)
  - [x] Offline download per track (subscribers only)
  - [x] Breathing animation, mini-player, onboarding
  - [x] Queue-based playback: Play All, prev/next, loop toggle
  - [x] Unified scrolling playlist detail (hero scrolls with tracks)

  Phase 2 — Audio & CDN ✓ DONE
  - [x] Convert all WAV files to AAC 192kbps stereo (87 tracks)
  - [x] Upload to Cloudflare R2, configure public dev domain
  - [x] Replace placeholder CDN URLs in Playlist.swift with real R2 URLs
  - [x] Hardcode track durations from ffprobe (shows m:ss in track list)
  - [x] Add isLoop flag to Track model; loop tracks show "Xm loop"
  - [x] Mini player shows album artwork instead of category icon
  - [x] Remove premium badges from album cards (lock stays on individual tracks)

  Phase 3 — StoreKit 2 ✓ DONE (local testing complete)
  - [x] Create local StoreKit configuration file (his-words.storekit) with test products
  - [x] Wire StoreKit 2 purchase flow in PaywallView (real purchase with verification)
  - [x] Verify entitlement on launch via Transaction.currentEntitlements
  - [x] Cache subscription status in UserDefaults (persists across app restarts)
  - [x] Add a "Manage Your Subscription" button to the UI
  - [x] Wire "Restore Purchases" button in PaywallView (calls AppStore.sync())
  - [x] Local sandbox testing on simulator

  Phase 4 — App Store Submission
  - [x] Add background audio in Xcode: Signing & Capabilities → Background Modes → Audio
  - [ ] Create app in App Store Connect
  - [ ] Set Bundle ID in Xcode (must match App Store Connect)
  - [ ] Create subscription products in App Store Connect (com.hiswords.monthly + com.hiswords.annual)
  - [ ] Configure In-App Purchase entitlements in Xcode
  - [ ] Add app icon (1024x1024 required for App Store)
  - [ ] Add launch screen or splash image
  - [ ] Set iOS minimum version + supported devices (portrait orientation)
  - [ ] Write app description, keywords, support email
  - [ ] Create App Store screenshots (6.5" iPhone Pro recommended)
  - [ ] Add privacy policy URL
  - [ ] Add age rating questionnaire
  - [ ] Test on real device + TestFlight
  - [ ] Submit to App Review

  ---
  TestFlight Testing Checklist

  When testing on TestFlight, verify:
  - [ ] Purchase monthly subscription → paywall closes, app unlocked
  - [ ] Purchase annual subscription → paywall closes, app unlocked
  - [ ] Delete and reinstall app → Restore Purchases finds subscription (should work on real device, not Xcode sandbox)
  - [ ] Tap "Manage Subscription" → Opens Apple Settings app to subscription management
  - [ ] Trial timer works (10 min lifetime, shows progress bar)
  - [ ] Download tracks while subscribed (stores in Documents)
  - [ ] Play downloaded tracks offline
  - [ ] Subscription syncs across multiple devices via Apple ID

  ---
  Key Decisions — Resolved

  1. Offline downloads for premium? → YES, implemented ✓
  2. No backend for v1 → StoreKit 2 + Apple ID handles cross-device sync ✓
  3. Trial model → 10 minutes lifetime (not per-day), local only ✓
  4. Track premium status → hardcoded in Playlist.swift for v1 ✓
  5. Audio format → AAC 192kbps stereo, streamed from Cloudflare R2 ✓
  6. Durations → hardcoded from ffprobe; catalog is fixed so no need to fetch at runtime ✓
