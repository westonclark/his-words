iPhone Meditation App — Plan

App Overview

A biblical affirmations and nature-sounds app. You pick a topic, then the ambient
bed you want it spoken over, and the set plays straight through — with the narrator
(male/female) and the voicing (1st person "I Am" / 2nd person "You Are") switchable
mid-listen. 10-minute lifetime free trial, then a subscription paywall.
Design inspired by Calm/Headspace.

---

Tech Stack

┌───────────────┬───────────────────────────────┬────────────────────────────────────────────────────────┐
│ Layer │ Choice │ Why │
├───────────────┼───────────────────────────────┼────────────────────────────────────────────────────────┤
│ Language │ Swift + SwiftUI │ Native iOS, best audio/animation support │
├───────────────┼───────────────────────────────┼────────────────────────────────────────────────────────┤
│ Audio │ AVFoundation + AVAudioSession │ Seamless looping, background playback, AirPlay │
├───────────────┼───────────────────────────────┼────────────────────────────────────────────────────────┤
│ Backend │ None (v1) │ StoreKit 2 syncs via Apple ID — no backend needed │
├───────────────┼───────────────────────────────┼────────────────────────────────────────────────────────┤
│ Subscriptions │ StoreKit 2 │ Native Apple IAP, syncs across devices via Apple ID │
├───────────────┼───────────────────────────────┼────────────────────────────────────────────────────────┤
│ Audio Storage │ Cloudflare R2 + CDN │ No egress fees, fast global streaming │
└───────────────┴───────────────────────────────┴────────────────────────────────────────────────────────┘

---

Audio Storage & Streaming Strategy

Store on Cloudflare R2, stream via CDN (not bundled in app)

- CDN base URL: https://pub-d6aadca8714e4a51804dc8762b7f9f6d.r2.dev ✓
- Audio files converted from WAV → AAC, delivered as .m4a ✓
- Users stream on demand — no large app download
- You can update/add files without an app update
- Free trial enforcement tracked locally via UserDefaults — 10 minutes lifetime, never resets
- Subscribers can download tracks for offline playback (stored in app Documents directory)
- isLoop flag on Track — used by the healing-frequencies loops

Bucket layout (mirrors the local AAC/ folder, uploaded under an audio/ prefix):

    audio/biblical-affirmations/{ambience}/{voice}/{person}/NN-title-slug-book-chapter-verses.m4a
    audio/healing-frequencies/{ambience}.m4a

where ambience ∈ ocean-waves | summer-night | thunderstorm | tranquil-river,
voice ∈ male | female, person ∈ i-am | you-are.

Filenames carry both the title and the verse, e.g.

    26-given-wisdom-and-spiritual-revelation-ephesians-1-15_22.m4a

The underscore is the verse-range separator (…-1-15_22 → Ephesians 1:15-22), which
is what lets chapter be told from range unambiguously. Keep that convention for any
recordings added later — the catalog's verse strings are derived from it.

⚠ UPLOAD IN PROGRESS (as of 2026-08-26) — the 4 healing-frequency loops are live,
and of the 16 affirmation folders only ocean-waves/female/you-are is up (all 30
files verified 200). Every other voice/person/ambience combination still 404s.
Note the app's default toggle state decides whether audio resolves at all.

- Track IDs are MD5-derived from the CDN path (Catalog.stableID), so offline
  downloads stay valid across launches and catalog edits ✓
- Durations are no longer hardcoded — there's no track-list UI to display them,
  so every Track carries duration 0 ✓
- Source files were renamed twice (verse-only slugs → title-only → title + verse);
  the catalog tables were regenerated from the folder listing each time and verified
  against all 16 ambience × voice × person directories ✓

---

Catalog — Topic → Ambience → Voice/Person

Defined in Models/Catalog.swift (replaced the old Models/Playlist.swift).

Topics:

1. Biblical Affirmations — featured, full voice/person matrix
2. Healing Frequencies — one loop track per ambience
3. Proverbs — Coming Soon (isAvailable = false, no navigation)
4. Prophecies — Coming Soon (isAvailable = false, no navigation)

Ambiences (all four available to both live topics): Ocean Waves, Summer Night,
Thunderstorm, Tranquil River.

Affirmation track counts by voice × person:

- male / i-am → 30 tracks
- female / i-am → 30 tracks
- female / you-are → 30 tracks
- male / you-are → 26 tracks (the last four were never recorded)

Structure — two tables, firstPersonTracks and secondPersonTracks, each an
[AffirmationTrack]. Every row holds both voices' cuts of that position:

    struct VoiceRecording { let file, title, verse: String }
    struct AffirmationTrack { let male, female: VoiceRecording? }

Each voice owns its own file, title, and verse, so the two recordings can diverge
freely — a different passage, a re-titled cut, a differently named file — without
disturbing each other. A nil variant means that voice never recorded the track,
which is how male / you-are ends at 26 (rows 27–30 are male: nil).

The 2nd-person sequence inserts "Led by the Spirit of God" at 21, so from there on
its numbering runs one ahead of the 1st-person sequence — the two tables are
deliberately NOT row-aligned, and shouldn't be "fixed" to line up.

Known per-voice divergences today are the track-26 verse citations:
male i-am 1:15-22 / female i-am 1:17-22, male you-are 1:3-22 / female you-are 1:15-22.

Each Track carries both a title and a verse reference, shown on two lines.

---

App Architecture

App
├── Onboarding (3 screens) ✓
├── Home ✓
│ ├── Featured topic card (Biblical Affirmations) ✓
│ ├── Topic grid — live topics navigate, Coming Soon ones don't ✓
│ └── "Get Premium" button (visible to non-subscribers) ✓
├── Ambience Selection ✓ (replaced Playlist Detail)
│ ├── List of ambience rows — thumbnail, name, and a short sound descriptor ✓
│ ├── Gold pill under the title — "30 tracks", or "Endless Loop" for a single isLoop track ✓
│ ├── "CHOOSE YOUR AMBIENCE" section label + "Pick the sound you'd like to rest in." ✓
│ └── Tap starts the topic from track 1 and opens the player ✓
├── Player Screen ✓
│ ├── Background image matches the selected ambience ✓
│ ├── Full title + verse reference on the line below ✓
│ ├── "X of Y" queue position ✓
│ ├── Prev / Play-Pause / Next — centered as a group ✓
│ ├── Male/Female toggle — restarts current track in the other voice ✓
│ ├── I Am / You Are toggle — restarts the set from track 1 ✓
│ ├── Both toggles persist globally (PlaybackPreferences) — new playback and new
│ │   launches start on the last chosen pair ✓
│ ├── No loop button, no close button (swipe down to dismiss) ✓
│ └── One progress slot, three states: trial countdown (non-subscribers),
│     scrubber (subscribers), or empty for an endless-loop track ✓
├── Mini Player ✓
│ ├── Shows artwork, title, and verse ✓
│ └── Lives on the NavigationStack, so it persists across pushes ✓
└── Paywall Screen ✓
└── Triggered at 10min lifetime or "Get Premium" ✓

---

Subscription Model

- Free tier: 10 cumulative minutes lifetime (tracked locally, never resets)
- Premium: $17.99/month or $119.99/year ($9.99/month equivalent — ~44% off vs monthly)
- StoreKit 2 handles everything: purchases, restores, family sharing, cross-device sync via Apple ID
- No backend needed — entitlement verified on-device via Transaction.currentEntitlements
- Offline downloads available to subscribers (files stored in app Documents directory)
- Per-track premium gating was dropped when playback became straight-through —
  every Track is isPremium = false and the 10-minute lifetime timer is the only gate

Paywall trigger points:

1. User hits 10-minute lifetime limit mid-session → player pauses, dismisses, paywall shows
2. User picks an ambience with the trial already exhausted
3. User taps "Get Premium" button on home screen

---

Design Direction (Calm/Headspace inspired)

- Color palette: Deep gray background, soft cream (#f0efea) text, muted gold accents ✓
- Typography: Serif headings + rounded sans body (system fonts) ✓
- Onboarding: 3 screens — icon, title, body copy → gold CTA button ✓
- No clutter: Player screen is nearly empty — visual, track name, and controls only ✓
- Topic/ambience cards show artwork only; "Coming Soon" pill on unavailable topics ✓
- AppBackground (Theme.swift): warm lift at top easing to deeper black at bottom —
  a few percent of luminance, so it reads as depth without competing with the photography ✓
- One glass material for controls: .ultraThinMaterial on both the mini player and
  the player's segmented toggles ✓
- Scrim behind the mini player fades content into the dark instead of cutting it ✓

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

Phase 4 — Content Model & UI Overhaul ✓ DONE

- [x] Replace Playlist.swift with Catalog.swift — Topic / Ambience / VoiceOption / PersonOption
- [x] Add PlaybackContext; AudioPlayerService rebuilds its own queue on a toggle
- [x] New flow: Home (topics) → Ambience Selection → straight-through playback
- [x] Delete PlaylistDetailView (no per-track list in the new flow)
- [x] Add verse to Track; player shows title + verse on two lines
- [x] Male/Female and I Am/You Are toggles in the player
- [x] Remove loop button and close button from the player
- [x] Proverbs + Prophecies as Coming Soon placeholders
- [x] Mini player lifted to NavigationStack level so it survives pushes
- [x] DownloadService writes .m4a; localURLProvider injected at launch
- [x] AppBackground gradient, glass mini player, scrim behind it
- [x] Asset cleanup: 66MB → 47MB (5 dead imagesets removed, ocean photo deduped)

Phase 4.5 — Ambience Picker Clarity ✓ DONE

- [x] Ambience grid → list, so it reads as a setting rather than a second content picker
- [x] Added Ambience.soundDescription so the names aren't a guess
- [x] Heading pill states the track count, or "Endless Loop" for loop topics
- [x] Catalog restructured to per-track male/female variants (see Catalog section)
- [x] CDN paths moved under the audio/ prefix (his-words is the bucket name, not part of the key)

Phase 4.6 — Playback Quality ✓ DONE

- [x] Seamless track transitions: one long-lived AVQueuePlayer with the remaining
      playlist enqueued up front, replacing the per-track AVPlayer teardown that
      caused an audible stop/start at every boundary
- [x] currentIndex now follows the player (KVO on currentItem) rather than driving it
- [x] Scrubber for subscribers — playbackTime / playbackDuration + seek, with an
      isScrubbing flag so the playhead doesn't fight the drag
- [x] Time observer moved to the persistent player and ticks at 0.25s;
      sessionSeconds advances by the tick length, so the trial timer still
      measures real seconds (TrialService reads deltas — keep that in step)
- [x] Endless-loop tracks rewind in place (actionAtItemEnd = .none) instead of
      draining the queue and re-fetching; no scrubber shown for them
- [x] Healing-frequency tracks titled "<Ambience> & Solfeggio Healing Frequencies"
- [x] Voice / person selections persisted in UserDefaults via PlaybackPreferences

Phase 5 — Upload & Verify (NEXT)

- [ ] Finish uploading AAC/ folder contents to R2 under audio/ (see Bucket layout above)
- [ ] Verify streaming for all 4 ambiences × 4 voice/person combos — the check parses
      the Swift tables and HEADs all 464 objects; re-run it against the live bucket
- [ ] Listen for gapless transitions on a real device (AAC encoder padding can still
      leave a seam the app can't fix — that would be an encode-side change)
- [ ] Verify offline download + playback with the new .m4a paths
- [ ] Optional: re-encode the 4 ambience PNGs as JPEG (~42MB of the 47MB remaining)

Phase 6 — App Store Submission

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
4. Track premium status → dropped; the 10-minute lifetime timer is the only gate ✓
5. Audio format → AAC, delivered as .m4a, streamed from Cloudflare R2 ✓
6. Durations → no longer needed; no track-list UI displays them ✓
7. Catalog shape → generated from Topic × Ambience × Voice × Person rather than
   hand-written playlists; track IDs are MD5-derived from the CDN path ✓
   Within that, each track lists its male and female cuts explicitly rather than
   sharing a base list with overrides — chosen for flexibility when the two voices
   need separate passages in a future release, at the cost of duplicated rows ✓
8. Playback → straight through from track 1; the ambience picker replaced the
   playlist/track-list screen ✓
9. Track transitions → AVQueuePlayer with everything enqueued ahead, not a player
   per track; the UI follows the player's currentItem ✓
10. Toggle state → global and persisted, not per-session ✓
