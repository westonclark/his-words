import Foundation

struct Playlist: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let category: Track.Category
    let tracks: [Track]
    let isPremium: Bool
}

// MARK: – Track lists (defined separately so the type-checker doesn't time out)

private let taylorWelchTracks: [Track] = [
    Track(id: UUID(uuidString: "6A000000-0000-0000-0000-000000000001")!, title: "Royal Heir of Yahweh",       category: .affirmations, duration: 0, streamURL: "https://your-cdn.com/audio/affirmations/royal-heir-of-yahweh.aac",       isPremium: true),
    Track(id: UUID(uuidString: "6A000000-0000-0000-0000-000000000002")!, title: "Blessings Chase Me Down",    category: .affirmations, duration: 0, streamURL: "https://your-cdn.com/audio/affirmations/blessings-chase-me-down.aac",    isPremium: true),
    Track(id: UUID(uuidString: "6A000000-0000-0000-0000-000000000003")!, title: "Blessed Beyond Measure",     category: .affirmations, duration: 0, streamURL: "https://your-cdn.com/audio/affirmations/blessed-beyond-measure.aac",     isPremium: true),
    Track(id: UUID(uuidString: "6A000000-0000-0000-0000-000000000004")!, title: "Everything I do Prospers",   category: .affirmations, duration: 0, streamURL: "https://your-cdn.com/audio/affirmations/everything-i-do-prospers.aac",   isPremium: true),
    Track(id: UUID(uuidString: "6A000000-0000-0000-0000-000000000005")!, title: "Supernatural Favor",         category: .affirmations, duration: 0, streamURL: "https://your-cdn.com/audio/affirmations/supernatural-favor.aac",         isPremium: true),
    Track(id: UUID(uuidString: "6A000000-0000-0000-0000-000000000006")!, title: "Successful in All I do",     category: .affirmations, duration: 0, streamURL: "https://your-cdn.com/audio/affirmations/successful-in-all-i-do.aac",     isPremium: true),
    Track(id: UUID(uuidString: "6A000000-0000-0000-0000-000000000007")!, title: "Heir of God",                category: .affirmations, duration: 0, streamURL: "https://your-cdn.com/audio/affirmations/heir-of-god.aac",                isPremium: true),
    Track(id: UUID(uuidString: "6A000000-0000-0000-0000-000000000008")!, title: "I do not Seek Peace",        category: .affirmations, duration: 0, streamURL: "https://your-cdn.com/audio/affirmations/i-do-not-seek-peace.aac",        isPremium: true),
    Track(id: UUID(uuidString: "6A000000-0000-0000-0000-000000000009")!, title: "I was Born to Win",          category: .affirmations, duration: 0, streamURL: "https://your-cdn.com/audio/affirmations/i-was-born-to-win.aac",          isPremium: true),
    Track(id: UUID(uuidString: "6A000000-0000-0000-0000-000000000010")!, title: "Fully Grateful",             category: .affirmations, duration: 0, streamURL: "https://your-cdn.com/audio/affirmations/fully-grateful.aac",             isPremium: true),
    Track(id: UUID(uuidString: "6A000000-0000-0000-0000-000000000011")!, title: "Advocate",                   category: .affirmations, duration: 0, streamURL: "https://your-cdn.com/audio/affirmations/advocate.aac",                   isPremium: true),
    Track(id: UUID(uuidString: "6A000000-0000-0000-0000-000000000012")!, title: "In Submission and in Flow",  category: .affirmations, duration: 0, streamURL: "https://your-cdn.com/audio/affirmations/in-submission-and-in-flow.aac",  isPremium: true),
    Track(id: UUID(uuidString: "6A000000-0000-0000-0000-000000000013")!, title: "Secure",                     category: .affirmations, duration: 0, streamURL: "https://your-cdn.com/audio/affirmations/secure.aac",                     isPremium: true),
    Track(id: UUID(uuidString: "6A000000-0000-0000-0000-000000000014")!, title: "I am Radiant",               category: .affirmations, duration: 0, streamURL: "https://your-cdn.com/audio/affirmations/i-am-radiant.aac",               isPremium: true),
    Track(id: UUID(uuidString: "6A000000-0000-0000-0000-000000000015")!, title: "Set High Above",             category: .affirmations, duration: 0, streamURL: "https://your-cdn.com/audio/affirmations/set-high-above.aac",             isPremium: true),
    Track(id: UUID(uuidString: "6A000000-0000-0000-0000-000000000016")!, title: "Honor",                      category: .affirmations, duration: 0, streamURL: "https://your-cdn.com/audio/affirmations/honor.aac",                      isPremium: true),
    Track(id: UUID(uuidString: "6A000000-0000-0000-0000-000000000017")!, title: "Blessed in Everything I do", category: .affirmations, duration: 0, streamURL: "https://your-cdn.com/audio/affirmations/blessed-in-everything-i-do.aac", isPremium: true),
    Track(id: UUID(uuidString: "6A000000-0000-0000-0000-000000000018")!, title: "Blessings of YHWH",          category: .affirmations, duration: 0, streamURL: "https://your-cdn.com/audio/affirmations/blessings-of-yhwh.aac",          isPremium: true),
]

private let biblicalTruthTracks: [Track] = [
    Track(id: UUID(uuidString: "7A000000-0000-0000-0000-000000000001")!, title: "Romans 5:17",         category: .affirmations, duration: 48,  streamURL: "https://your-cdn.com/audio/biblical/romans-5-17.aac",         isPremium: true),
    Track(id: UUID(uuidString: "7A000000-0000-0000-0000-000000000002")!, title: "2 Corinthians 4:18",  category: .affirmations, duration: 48,  streamURL: "https://your-cdn.com/audio/biblical/2-corinthians-4-18.aac",  isPremium: true),
    Track(id: UUID(uuidString: "7A000000-0000-0000-0000-000000000003")!, title: "2 Corinthians 5:7",   category: .affirmations, duration: 32,  streamURL: "https://your-cdn.com/audio/biblical/2-corinthians-5-7.aac",   isPremium: true),
    Track(id: UUID(uuidString: "7A000000-0000-0000-0000-000000000004")!, title: "2 Corinthians 10:4-5",category: .affirmations, duration: 53,  streamURL: "https://your-cdn.com/audio/biblical/2-corinthians-10-4-5.aac",isPremium: true),
    Track(id: UUID(uuidString: "7A000000-0000-0000-0000-000000000005")!, title: "2 Corinthians 5:21",  category: .affirmations, duration: 42,  streamURL: "https://your-cdn.com/audio/biblical/2-corinthians-5-21.aac",  isPremium: true),
    Track(id: UUID(uuidString: "7A000000-0000-0000-0000-000000000006")!, title: "Ephesians 3:14-19",   category: .affirmations, duration: 97,  streamURL: "https://your-cdn.com/audio/biblical/ephesians-3-14-19.aac",   isPremium: true),
    Track(id: UUID(uuidString: "7A000000-0000-0000-0000-000000000007")!, title: "Ephesians 2:10",      category: .affirmations, duration: 95,  streamURL: "https://your-cdn.com/audio/biblical/ephesians-2-10.aac",      isPremium: true),
    Track(id: UUID(uuidString: "7A000000-0000-0000-0000-000000000008")!, title: "2 Peter 1:2-4",       category: .affirmations, duration: 92,  streamURL: "https://your-cdn.com/audio/biblical/2-peter-1-2-4.aac",       isPremium: true),
    Track(id: UUID(uuidString: "7A000000-0000-0000-0000-000000000009")!, title: "3 John 1:2",          category: .affirmations, duration: 56,  streamURL: "https://your-cdn.com/audio/biblical/3-john-1-2.aac",          isPremium: true),
    Track(id: UUID(uuidString: "7A000000-0000-0000-0000-000000000010")!, title: "Romans 12:2",         category: .affirmations, duration: 60,  streamURL: "https://your-cdn.com/audio/biblical/romans-12-2.aac",         isPremium: true),
    Track(id: UUID(uuidString: "7A000000-0000-0000-0000-000000000011")!, title: "1 Peter 2:21-24",     category: .affirmations, duration: 102, streamURL: "https://your-cdn.com/audio/biblical/1-peter-2-21-24.aac",     isPremium: true),
    Track(id: UUID(uuidString: "7A000000-0000-0000-0000-000000000012")!, title: "Romans 8:37-39",      category: .affirmations, duration: 74,  streamURL: "https://your-cdn.com/audio/biblical/romans-8-37-39.aac",      isPremium: true),
    Track(id: UUID(uuidString: "7A000000-0000-0000-0000-000000000013")!, title: "Matthew 5:13-16",     category: .affirmations, duration: 75,  streamURL: "https://your-cdn.com/audio/biblical/matthew-5-13-16.aac",     isPremium: true),
    Track(id: UUID(uuidString: "7A000000-0000-0000-0000-000000000014")!, title: "Colossians 2:9-10",   category: .affirmations, duration: 63,  streamURL: "https://your-cdn.com/audio/biblical/colossians-2-9-10.aac",   isPremium: true),
]

// MARK: – Catalog
// Replace streamURL values with your actual Cloudflare R2 / CDN URLs.
extension Playlist {
    static let catalog: [Playlist] = [
        Playlist(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            title: "Wind & Sky",
            subtitle: "Open air and drifting clouds",
            category: .wind,
            tracks: [
                Track(id: UUID(uuidString: "4A000000-0000-0000-0000-000000000001")!, title: "Meadow Breeze", category: .wind, duration: 3600, streamURL: "https://your-cdn.com/audio/meadow-breeze.aac", isPremium: false),
                Track(id: UUID(uuidString: "4A000000-0000-0000-0000-000000000002")!, title: "Mountain Wind", category: .wind, duration: 3600, streamURL: "https://your-cdn.com/audio/mountain-wind.aac", isPremium: true),
            ],
            isPremium: false
        ),
        Playlist(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
            title: "Fireside",
            subtitle: "Crackling warmth and amber glow",
            category: .fire,
            tracks: [
                Track(id: UUID(uuidString: "5A000000-0000-0000-0000-000000000001")!, title: "Hearthfire", category: .fire, duration: 3600, streamURL: "https://your-cdn.com/audio/hearthfire.aac", isPremium: false),
                Track(id: UUID(uuidString: "5A000000-0000-0000-0000-000000000002")!, title: "Campfire",   category: .fire, duration: 3600, streamURL: "https://your-cdn.com/audio/campfire.aac",   isPremium: true),
            ],
            isPremium: false
        ),
        Playlist(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
            title: "Daily Affirmations: As a Child of a King",
            subtitle: "The Taylor Welch Collection",
            category: .affirmations,
            tracks: taylorWelchTracks,
            isPremium: true
        ),
        Playlist(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000007")!,
            title: "Biblical Truth Affirmations + Sounds of Thunder & 528Hz",
            subtitle: "His Words • 2025",
            category: .affirmations,
            tracks: biblicalTruthTracks,
            isPremium: true
        ),
    ]

    static var featured: Playlist { catalog[0] }
}
