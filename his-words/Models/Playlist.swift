import Foundation

private let cdnBase = "https://YOUR_R2_PUBLIC_URL"

struct Playlist: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let category: Track.Category
    let tracks: [Track]
    let isPremium: Bool
    let imageName: String?

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Playlist, rhs: Playlist) -> Bool { lhs.id == rhs.id }
}

// MARK: – Track lists (module-level to avoid type-checker timeout)

private let affirmationsConfidenceTracks: [Track] = [
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000001")!, title: "God's Masterpiece",                  category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/01-gods-masterpiece.aac",                  isPremium: false),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000002")!, title: "Radiant",                            category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/02-radiant.aac",                            isPremium: false),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000003")!, title: "Continually Renewed",                category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/03-continually-renewed.aac",                isPremium: false),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000004")!, title: "Renewed by the Word of God",         category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/04-renewed-by-the-word-of-god.aac",         isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000005")!, title: "Yahweh's Special People",            category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/05-yahwehs-special-people.aac",            isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000006")!, title: "Never Put to Shame",                 category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/06-never-put-to-shame.aac",                 isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000007")!, title: "Walking by Faith",                   category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/07-walking-by-faith.aac",                   isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000008")!, title: "Walking by Faith, Pt. 2",            category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/08-walking-by-faith-pt-2.aac",              isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000009")!, title: "Casting Down Imaginations",          category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/09-casting-down-imaginations.aac",          isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000010")!, title: "Chosen Race",                        category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/10-chosen-race.aac",                        isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000011")!, title: "Reigning in Life",                   category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/11-reigning-in-life.aac",                   isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000012")!, title: "Righteousness of God",               category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/12-righteousness-of-god.aac",               isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000013")!, title: "Complete in Christ",                 category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/13-complete-in-christ.aac",                 isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000014")!, title: "Ephesians 3 Prayer",                 category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/14-ephesians-3-prayer.aac",                 isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000015")!, title: "Strengthened with Might",            category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/15-strengthened-with-might.aac",            isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000016")!, title: "Rooted and Grounded in Love",        category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/16-rooted-and-grounded-in-love.aac",        isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000017")!, title: "Rooted and Grounded in Love, Pt. 2", category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/17-rooted-and-grounded-in-love-pt2.aac",   isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000018")!, title: "Depth of Christ's Love",             category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/18-depth-of-christs-love.aac",              isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000019")!, title: "Filled with All the Fullness of God",category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/19-filled-with-all-the-fullness-of-god.aac",isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000020")!, title: "2 Peter 1:2-4",                      category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/20-2-peter-1-2-4.aac",                      isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000021")!, title: "Grace and Peace Multiplied",         category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/21-grace-and-peace-multiplied.aac",         isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000022")!, title: "Everything You Need",                category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/22-everything-you-need.aac",                isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000023")!, title: "Partaker of God's Divine Nature",    category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/23-partaker-of-gods-divine-nature.aac",     isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000024")!, title: "More than a Conqueror",              category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/24-more-than-a-conqueror.aac",              isPremium: true),
    Track(id: UUID(uuidString: "A0000000-0000-0000-0000-000000000025")!, title: "Ephesians 6",                        category: .affirmations, duration: 0, streamURL: "\(cdnBase)/audio/affirmations-confidence-healing/25-ephesians-6.aac",                        isPremium: true),
]

private let biblicalThunderstormsTracks: [Track] = [
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000001")!, title: "Romans 5:17",           category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/01-romans-5-17.aac",           isPremium: false),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000002")!, title: "2 Corinthians 4:18",    category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/02-2-corinthians-4-18.aac",    isPremium: false),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000003")!, title: "2 Corinthians 5:7",     category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/03-2-corinthians-5-7.aac",     isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000004")!, title: "2 Corinthians 10:4-5",  category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/04-2-corinthians-10-4-5.aac",  isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000005")!, title: "2 Corinthians 5:21",    category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/05-2-corinthians-5-21.aac",    isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000006")!, title: "Ephesians 3:14-19",     category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/06-ephesians-3-14-19.aac",     isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000007")!, title: "Ephesians 2:10",        category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/07-ephesians-2-10.aac",        isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000008")!, title: "2 Peter 1:2-4",         category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/08-2-peter-1-2-4.aac",         isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000009")!, title: "3 John 1:2",            category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/09-3-john-1-2.aac",            isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000010")!, title: "Romans 12:2",           category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/10-romans-12-2.aac",           isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000011")!, title: "1 Peter 2:21-24",       category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/11-1-peter-2-21-24.aac",       isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000012")!, title: "Romans 8:37-39",        category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/12-romans-8-37-39.aac",        isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000013")!, title: "Matthew 5:13-16",       category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/13-matthew-5-13-16.aac",       isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000014")!, title: "Colossians 2:9-10",     category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/14-colossians-2-9-10.aac",     isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000015")!, title: "Ephesians 6:10-20",     category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/15-ephesians-6-10-20.aac",     isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000016")!, title: "Ephesians 6:16",        category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/16-ephesians-6-16.aac",        isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000017")!, title: "Joshua 1:7-9",          category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/17-joshua-1-7-9.aac",          isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000018")!, title: "Joshua 1:9",            category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/18-joshua-1-9.aac",            isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000019")!, title: "Psalms 1:1-3",          category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/19-psalms-1-1-3.aac",          isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000020")!, title: "1 Corinthians 6:19-20", category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/20-1-corinthians-6-19-20.aac", isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000021")!, title: "Romans 8:14",           category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/21-romans-8-14.aac",           isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000022")!, title: "Romans 8:14, Part 2",   category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/22-romans-8-14-part-2.aac",   isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000023")!, title: "Romans 8:1-6",          category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/23-romans-8-1-6.aac",          isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000024")!, title: "Philippians 4:19",      category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/24-philippians-4-19.aac",      isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000025")!, title: "1 Peter 5:6-7",         category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/25-i-peter-5-6-7.aac",         isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000026")!, title: "Ephesians 1:3-23",      category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/26-ephesians-1-3-23.aac",      isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000027")!, title: "Romans 8:15-17",        category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/27-romans-8-15-17.aac",        isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000028")!, title: "1 Thessalonians 3:12-13",category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/28-i-thessalonians-3-12-13.aac",isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000029")!, title: "Hebrews 13:20-21",      category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/29-hebrews-13-20-21.aac",      isPremium: true),
    Track(id: UUID(uuidString: "B0000000-0000-0000-0000-000000000030")!, title: "Psalms 51:15",          category: .rain, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-thunderstorms/30-psalms-51-15.aac",          isPremium: true),
]

private let biblicalOceanWavesTracks: [Track] = [
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000001")!, title: "Romans 5:17",            category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/01-romans-5-17.aac",            isPremium: false),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000002")!, title: "2 Corinthians 4:18",     category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/02-2-corinthians-4-18.aac",     isPremium: false),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000003")!, title: "2 Corinthians 5:7",      category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/03-2-corinthians-5-7.aac",      isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000004")!, title: "2 Corinthians 10:4-5",   category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/04-2-corinthians-10-4-5.aac",   isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000005")!, title: "2 Corinthians 5:21",     category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/05-2-corinthians-5-21.aac",     isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000006")!, title: "Ephesians 3:14-19",      category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/06-ephesians-3-14-19.aac",      isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000007")!, title: "Ephesians 2:10",         category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/07-ephesians-2-10.aac",         isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000008")!, title: "2 Peter 1:2-4",          category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/08-2-peter-1-2-4.aac",          isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000009")!, title: "3 John 1:2",             category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/09-3-john-1-2.aac",             isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000010")!, title: "Romans 12:2",            category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/10-romans-12-2.aac",            isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000011")!, title: "1 Peter 2:21-24",        category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/11-1-peter-2-21-24.aac",        isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000012")!, title: "Romans 8:37-39",         category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/12-romans-8-37-39.aac",         isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000013")!, title: "Matthew 5:13-16",        category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/13-matthew-5-13-16.aac",        isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000014")!, title: "Colossians 2:9-10",      category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/14-colossians-2-9-10.aac",      isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000015")!, title: "Ephesians 6:10-20",      category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/15-ephesians-6-10-20.aac",      isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000016")!, title: "Ephesians 6:16",         category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/16-ephesians-6-16.aac",         isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000017")!, title: "Joshua 1:7-9",           category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/17-joshua-1-7-9.aac",           isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000018")!, title: "Joshua 1:9",             category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/18-joshua-1-9.aac",             isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000019")!, title: "Psalms 1:1-3",           category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/19-psalms-1-1-3.aac",           isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000020")!, title: "1 Corinthians 6:19-20",  category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/20-1-corinthians-6-19-20.aac",  isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000021")!, title: "Romans 8:14",            category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/21-romans-8-14.aac",            isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000022")!, title: "Romans 8:14, Part 2",    category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/22-romans-8-14-part-2.aac",    isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000023")!, title: "Romans 8:1-6",           category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/23-romans-8-1-6.aac",           isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000024")!, title: "Philippians 4:19",       category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/24-philippians-4-19.aac",       isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000025")!, title: "1 Peter 5:6-7",          category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/25-i-peter-5-6-7.aac",          isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000026")!, title: "Ephesians 1:3-23",       category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/26-ephesians-1-3-23.aac",       isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000027")!, title: "Romans 8:15-17",         category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/27-romans-8-15-17.aac",         isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000028")!, title: "1 Thessalonians 3:12-13",category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/28-i-thessalonians-3-12-13.aac",isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000029")!, title: "Hebrews 13:20-21",       category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/29-hebrews-13-20-21.aac",       isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000030")!, title: "Psalms 51:15",           category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/30-psalms-51-15.aac",           isPremium: true),
    Track(id: UUID(uuidString: "C0000000-0000-0000-0000-000000000031")!, title: "852Hz — Amen",           category: .ocean, duration: 0, streamURL: "\(cdnBase)/audio/biblical-identity-ocean-waves/31-852hz-amen.aac",             isPremium: true),
]

// MARK: – Catalog

extension Playlist {
    static let catalog: [Playlist] = [
        Playlist(
            id: UUID(uuidString: "00000001-0000-0000-0000-000000000000")!,
            title: "Affirmations for Confidence + Healing Frequencies",
            subtitle: "Walk in the fullness of who God made you",
            category: .affirmations,
            tracks: affirmationsConfidenceTracks,
            isPremium: true,
            imageName: "affirmations-confidence-healing"
        ),
        Playlist(
            id: UUID(uuidString: "00000002-0000-0000-0000-000000000000")!,
            title: "Biblical Identity Affirmations + Thunderstorms & 528Hz",
            subtitle: "Scripture-rooted identity over thunder and healing tones",
            category: .rain,
            tracks: biblicalThunderstormsTracks,
            isPremium: true,
            imageName: "biblical-identity-thunderstorms"
        ),
        Playlist(
            id: UUID(uuidString: "00000003-0000-0000-0000-000000000000")!,
            title: "Biblical Identity Affirmations + Ocean Waves & Solfeggio Frequencies",
            subtitle: "Scripture-rooted identity over ocean waves and solfeggio tones",
            category: .ocean,
            tracks: biblicalOceanWavesTracks,
            isPremium: true,
            imageName: "biblical-identity-ocean-waves"
        ),
        Playlist(
            id: UUID(uuidString: "00000004-0000-0000-0000-000000000000")!,
            title: "Ocean Waves + Healing Frequencies for Sleep",
            subtitle: "One hour of ocean waves and healing frequencies",
            category: .ocean,
            tracks: [
                Track(id: UUID(uuidString: "D0000000-0000-0000-0000-000000000001")!, title: "Ocean Waves + Healing Frequencies", category: .ocean, duration: 3600, streamURL: "\(cdnBase)/audio/ocean-waves-sleep/01-ocean-waves-healing-sleep.aac", isPremium: false),
            ],
            isPremium: false,
            imageName: "ocean-waves-sleep"
        ),
    ]

    static var featured: Playlist { catalog[0] }
}
