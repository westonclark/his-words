import CryptoKit
import Foundation

private let cdnBase = "https://pub-d6aadca8714e4a51804dc8762b7f9f6d.r2.dev"

/// Everything lives under this prefix in the R2 bucket.
private let audioBase = "audio"

// MARK: – Topic

enum Topic: String, CaseIterable, Identifiable, Hashable {
    case biblicalAffirmations = "biblical-affirmations"
    case childOfAKing         = "child-of-a-king"
    case healingFrequencies   = "healing-frequencies"
    case paulsPrayers = "pauls-prayers"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .biblicalAffirmations: return "Biblical Affirmations"
        case .healingFrequencies:   return "Nature Sounds & Healing Frequencies"
        case .childOfAKing:         return "As a Child of a King"
        case .paulsPrayers:         return "Paul's Prayers"
        }
    }

    var subtitle: String {
        switch self {
        case .biblicalAffirmations: return "Scripture-rooted identity, spoken over you"
        case .healingFrequencies:   return "Solfeggio tones for rest and restoration"
        case .childOfAKing:         return "Fifty declarations of who you are in Him"
        case .paulsPrayers:         return "Coming soon"
        }
    }

    var isAvailable: Bool {
        switch self {
        case .biblicalAffirmations, .healingFrequencies, .childOfAKing: return true
        case .paulsPrayers: return false
        }
    }

    var imageName: String? {
        switch self {
        case .biblicalAffirmations: return "topic-biblical-affirmations"
        case .healingFrequencies:   return Ambience.oceanWaves.imageName
        case .childOfAKing:         return "topic-child-of-a-king"
        case .paulsPrayers:         return nil
        }
    }

    var icon: String {
        switch self {
        case .biblicalAffirmations: return "text.bubble.fill"
        case .healingFrequencies:   return "waveform"
        case .childOfAKing:         return "crown.fill"
        case .paulsPrayers:         return "hands.sparkles.fill"
        }
    }

    /// Whether the voice / person toggles apply to this topic's audio.
    var hasVoiceOptions: Bool { self == .biblicalAffirmations || self == .childOfAKing }

    static let featured: Topic = .biblicalAffirmations
}

// MARK: – Ambience

enum Ambience: String, CaseIterable, Identifiable, Hashable {
    case oceanWaves    = "ocean-waves"
    case summerNight   = "summer-night"
    case thunderstorm
    case tranquilRiver = "tranquil-river"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .oceanWaves:    return "Ocean Waves"
        case .summerNight:   return "Summer Night"
        case .thunderstorm:  return "Thunderstorm"
        case .tranquilRiver: return "Tranquil River"
        }
    }

    /// Short cue for what you'll actually hear, so the names aren't a guess.
    var soundDescription: String {
        switch self {
        case .oceanWaves:    return "Steady waves on the shoreline"
        case .summerNight:   return "Chirping crickets and still night air"
        case .thunderstorm:  return "Distant rolling thunder"
        case .tranquilRiver: return "Running water through a creek bed"
        }
    }

    var imageName: String { "ambience-\(rawValue)" }

    var category: Track.Category {
        switch self {
        case .oceanWaves:    return .ocean
        case .summerNight:   return .wind
        case .thunderstorm:  return .rain
        case .tranquilRiver: return .forest
        }
    }
}

// MARK: – Voice & person

enum VoiceOption: String, CaseIterable, Identifiable, Hashable {
    case male, female
    var id: String { rawValue }
    var label: String { self == .male ? "Male" : "Female" }
}

enum PersonOption: String, CaseIterable, Identifiable, Hashable {
    case firstPerson  = "i-am"
    case secondPerson = "you-are"

    var id: String { rawValue }
    var label: String { self == .firstPerson ? "I Am" : "You Are" }
}

// MARK: – Playback context

struct PlaybackContext: Hashable {
    var topic: Topic
    var ambience: Ambience
    var voice: VoiceOption
    var person: PersonOption

    /// New playback picks up wherever the listener left the toggles, so the
    /// choice carries across topics, ambiences, and app launches.
    init(
        topic: Topic,
        ambience: Ambience,
        voice: VoiceOption = PlaybackPreferences.voice,
        person: PersonOption = PlaybackPreferences.person
    ) {
        self.topic = topic
        self.ambience = ambience
        self.voice = voice
        self.person = person
    }

    var imageName: String { ambience.imageName }
}

// MARK: – Remembered toggle state

/// The last voice / person the listener chose, persisted across launches.
enum PlaybackPreferences {
    private static let voiceKey  = "playback_voice"
    private static let personKey = "playback_person"

    static var voice: VoiceOption {
        get {
            UserDefaults.standard.string(forKey: voiceKey)
                .flatMap(VoiceOption.init(rawValue:)) ?? .female
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: voiceKey) }
    }

    static var person: PersonOption {
        get {
            UserDefaults.standard.string(forKey: personKey)
                .flatMap(PersonOption.init(rawValue:)) ?? .firstPerson
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: personKey) }
    }
}

// MARK: – Catalog

enum Catalog {
    static func tracks(for context: PlaybackContext) -> [Track] {
        switch context.topic {
        case .biblicalAffirmations:
            return affirmationTracks(context)
        case .healingFrequencies:
            return [healingFrequencyTrack(context.ambience)]
        case .childOfAKing:
            return childOfAKingTracks(context)
        case .paulsPrayers:
            return []
        }
    }

    private static func affirmationTracks(_ context: PlaybackContext) -> [Track] {
        tracks(
            for: context,
            topicFolder: "biblical-affirmations",
            recordings: entries(voice: context.voice, person: context.person)
        )
    }

    private static func childOfAKingTracks(_ context: PlaybackContext) -> [Track] {
        tracks(for: context, topicFolder: "child-of-a-king", recordings: childOfAKingRecordings)
    }

    private static func tracks(
        for context: PlaybackContext,
        topicFolder: String,
        recordings: [VoiceRecording]
    ) -> [Track] {
        recordings.map { recording in
            let path = "\(audioBase)/\(topicFolder)/\(context.ambience.rawValue)/\(context.voice.rawValue)/\(context.person.rawValue)/\(recording.file).m4a"
            return Track(
                id: stableID(path),
                title: recording.title,
                verse: recording.verse,
                category: context.ambience.category,
                duration: 0,
                streamURL: "\(cdnBase)/\(path)",
                isPremium: false
            )
        }
    }

    /// Piano albums under healing-frequencies/<album folder>/<file>.m4a.
    static func tracks(for album: HealingAlbum) -> [Track] {
        album.recordings.map { recording in
            let path = "\(audioBase)/healing-frequencies/\(album.folder)/\(recording.file).m4a"
            return Track(
                id: stableID(path),
                title: recording.title,
                verse: album.title,
                category: album.category,
                duration: 0,
                streamURL: "\(cdnBase)/\(path)",
                isPremium: false
            )
        }
    }

    private static func healingFrequencyTrack(_ ambience: Ambience) -> Track {
        let path = "\(audioBase)/healing-frequencies/\(ambience.rawValue).m4a"
        return Track(
            id: stableID(path),
            title: ambience.displayName,
            verse: "Solfeggio Healing Frequencies",
            category: ambience.category,
            duration: 0,
            streamURL: "\(cdnBase)/\(path)",
            isPremium: false,
            isLoop: true
        )
    }

    /// The tracks one voice actually recorded for a person-form, in order.
    private static func entries(voice: VoiceOption, person: PersonOption) -> [VoiceRecording] {
        let tracks = person == .firstPerson ? firstPersonTracks : secondPersonTracks
        return tracks.compactMap { $0.recording(for: voice) }
    }

    /// Stable, content-derived UUID so downloads survive relaunches.
    private static func stableID(_ key: String) -> UUID {
        var bytes = Array(Insecure.MD5.hash(data: Data(key.utf8)))
        bytes[6] = (bytes[6] & 0x0F) | 0x40  // version 4
        bytes[8] = (bytes[8] & 0x3F) | 0x80  // RFC 4122 variant
        return bytes.withUnsafeBytes { UUID(uuid: $0.load(as: uuid_t.self)) }
    }
}

// MARK: – Affirmation track listings

/// One voice's cut of one track. Each voice owns its own file, title, and
/// verse, so the two recordings can diverge freely — a different passage, a
/// re-titled cut, a differently named file — without disturbing each other.
struct VoiceRecording {
    let file: String
    let title: String
    let verse: String
}

/// A single position in the sequence, holding both voices' cuts of it.
/// A `nil` variant means that voice never recorded this track.
struct AffirmationTrack {
    let male: VoiceRecording?
    let female: VoiceRecording?

    func recording(for voice: VoiceOption) -> VoiceRecording? {
        switch voice {
        case .male:   return male
        case .female: return female
        }
    }
}

/// The 1st-person sequence.
private let firstPersonTracks: [AffirmationTrack] = [
    .init(  // 01
        male: .init(
            file:  "01-reigning-in-life-romans-5-17",
            title: "Reigning in Life",
            verse: "Romans 5:17"
        ),
        female: .init(
            file:  "01-reigning-in-life-romans-5-17",
            title: "Reigning in Life",
            verse: "Romans 5:17"
        )
    ),
    .init(  // 02
        male: .init(
            file:  "02-eternal-perspective-2-corinthians-4-18",
            title: "Eternal Perspective",
            verse: "2 Corinthians 4:18"
        ),
        female: .init(
            file:  "02-eternal-perspective-2-corinthians-4-18",
            title: "Eternal Perspective",
            verse: "2 Corinthians 4:18"
        )
    ),
    .init(  // 03
        male: .init(
            file:  "03-walking-by-faith-2-corinthians-5-7",
            title: "Walking by Faith",
            verse: "2 Corinthians 5:7"
        ),
        female: .init(
            file:  "03-walking-by-faith-2-corinthians-5-7",
            title: "Walking by Faith",
            verse: "2 Corinthians 5:7"
        )
    ),
    .init(  // 04
        male: .init(
            file:  "04-casting-down-imaginations-2-corinthians-10-4_5",
            title: "Casting Down Imaginations",
            verse: "2 Corinthians 10:4-5"
        ),
        female: .init(
            file:  "04-casting-down-imaginations-2-corinthians-10-4_5",
            title: "Casting Down Imaginations",
            verse: "2 Corinthians 10:4-5"
        )
    ),
    .init(  // 05
        male: .init(
            file:  "05-righteousness-of-god-2-corinthians-5-21",
            title: "Righteousness of God",
            verse: "2 Corinthians 5:21"
        ),
        female: .init(
            file:  "05-righteousness-of-god-2-corinthians-5-21",
            title: "Righteousness of God",
            verse: "2 Corinthians 5:21"
        )
    ),
    .init(  // 06
        male: .init(
            file:  "06-rooted-and-grounded-in-love-ephesians-3-14_19",
            title: "Rooted and Grounded in Love",
            verse: "Ephesians 3:14-19"
        ),
        female: .init(
            file:  "06-rooted-and-grounded-in-love-ephesians-3-14_19",
            title: "Rooted and Grounded in Love",
            verse: "Ephesians 3:14-19"
        )
    ),
    .init(  // 07
        male: .init(
            file:  "07-gods-masterpiece-ephesians-2-10",
            title: "God's Masterpiece",
            verse: "Ephesians 2:10"
        ),
        female: .init(
            file:  "07-gods-masterpiece-ephesians-2-10",
            title: "God's Masterpiece",
            verse: "Ephesians 2:10"
        )
    ),
    .init(  // 08
        male: .init(
            file:  "08-partaker-of-gods-divine-nature-2-peter-1-2_4",
            title: "Partaker of God's Divine Nature",
            verse: "2 Peter 1:2-4"
        ),
        female: .init(
            file:  "08-partaker-of-gods-divine-nature-2-peter-1-2_4",
            title: "Partaker of God's Divine Nature",
            verse: "2 Peter 1:2-4"
        )
    ),
    .init(  // 09
        male: .init(
            file:  "09-prosperous-and-in-good-health-3-john-1-2",
            title: "Prosperous and in Good Health",
            verse: "3 John 1:2"
        ),
        female: .init(
            file:  "09-prosperous-and-in-good-health-3-john-1-2",
            title: "Prosperous and in Good Health",
            verse: "3 John 1:2"
        )
    ),
    .init(  // 10
        male: .init(
            file:  "10-transformed-with-a-renewed-mind-romans-12-2",
            title: "Transformed with a Renewed Mind",
            verse: "Romans 12:2"
        ),
        female: .init(
            file:  "10-transformed-with-a-renewed-mind-romans-12-2",
            title: "Transformed with a Renewed Mind",
            verse: "Romans 12:2"
        )
    ),
    .init(  // 11
        male: .init(
            file:  "11-healed-1-peter-2-21_24",
            title: "Healed",
            verse: "1 Peter 2:21-24"
        ),
        female: .init(
            file:  "11-healed-1-peter-2-21_24",
            title: "Healed",
            verse: "1 Peter 2:21-24"
        )
    ),
    .init(  // 12
        male: .init(
            file:  "12-conqueror-romans-8-37_39",
            title: "Conqueror",
            verse: "Romans 8:37-39"
        ),
        female: .init(
            file:  "12-conqueror-romans-8-37_39",
            title: "Conqueror",
            verse: "Romans 8:37-39"
        )
    ),
    .init(  // 13
        male: .init(
            file:  "13-salt-of-the-earth-and-light-of-the-world-matthew-5-13_16",
            title: "Salt of the Earth & Light of the World",
            verse: "Matthew 5:13-16"
        ),
        female: .init(
            file:  "13-salt-of-the-earth-and-light-of-the-world-matthew-5-13_16",
            title: "Salt of the Earth & Light of the World",
            verse: "Matthew 5:13-16"
        )
    ),
    .init(  // 14
        male: .init(
            file:  "14-complete-colossians-2-9_10",
            title: "Complete",
            verse: "Colossians 2:9-10"
        ),
        female: .init(
            file:  "14-complete-colossians-2-9_10",
            title: "Complete",
            verse: "Colossians 2:9-10"
        )
    ),
    .init(  // 15
        male: .init(
            file:  "15-strong-ephesians-6-10_20",
            title: "Strong",
            verse: "Ephesians 6:10-20"
        ),
        female: .init(
            file:  "15-strong-ephesians-6-10_20",
            title: "Strong",
            verse: "Ephesians 6:10-20"
        )
    ),
    .init(  // 16
        male: .init(
            file:  "16-quenching-all-fiery-darts-ephesians-6-16",
            title: "Quenching All Fiery Darts",
            verse: "Ephesians 6:16"
        ),
        female: .init(
            file:  "16-quenching-all-fiery-darts-ephesians-6-16",
            title: "Quenching All Fiery Darts",
            verse: "Ephesians 6:16"
        )
    ),
    .init(  // 17
        male: .init(
            file:  "17-meditating-on-the-words-of-god-joshua-1-7_9",
            title: "Meditating on the Words of God",
            verse: "Joshua 1:7-9"
        ),
        female: .init(
            file:  "17-meditating-on-the-words-of-god-joshua-1-7_9",
            title: "Meditating on the Words of God",
            verse: "Joshua 1:7-9"
        )
    ),
    .init(  // 18
        male: .init(
            file:  "18-strong-and-courageous-joshua-1-9",
            title: "Strong & Courageous",
            verse: "Joshua 1:9"
        ),
        female: .init(
            file:  "18-strong-and-courageous-joshua-1-9",
            title: "Strong & Courageous",
            verse: "Joshua 1:9"
        )
    ),
    .init(  // 19
        male: .init(
            file:  "19-flourishing-and-prosperous-psalm-1-1_3",
            title: "Flourishing & Prosperous",
            verse: "Psalm 1:1-3"
        ),
        female: .init(
            file:  "19-flourishing-and-prosperous-psalm-1-1_3",
            title: "Flourishing & Prosperous",
            verse: "Psalm 1:1-3"
        )
    ),
    .init(  // 20
        male: .init(
            file:  "20-temple-of-the-holy-ghost-1-corinthians-6-19_20",
            title: "Temple of the Holy Ghost",
            verse: "1 Corinthians 6:19-20"
        ),
        female: .init(
            file:  "20-temple-of-the-holy-ghost-1-corinthians-6-19_20",
            title: "Temple of the Holy Ghost",
            verse: "1 Corinthians 6:19-20"
        )
    ),
    .init(  // 21
        male: .init(
            file:  "21-child-of-god-romans-8-14",
            title: "Child of God",
            verse: "Romans 8:14"
        ),
        female: .init(
            file:  "21-child-of-god-romans-8-14",
            title: "Child of God",
            verse: "Romans 8:14"
        )
    ),
    .init(  // 22
        male: .init(
            file:  "22-spiritually-minded-romans-8-1_6",
            title: "Spiritually Minded",
            verse: "Romans 8:1-6"
        ),
        female: .init(
            file:  "22-spiritually-minded-romans-8-1_6",
            title: "Spiritually Minded",
            verse: "Romans 8:1-6"
        )
    ),
    .init(  // 23
        male: .init(
            file:  "23-receiving-every-need-met-philippians-4-19",
            title: "Receiving Every Need Met",
            verse: "Philippians 4:19"
        ),
        female: .init(
            file:  "23-receiving-every-need-met-philippians-4-19",
            title: "Receiving Every Need Met",
            verse: "Philippians 4:19"
        )
    ),
    .init(  // 24
        male: .init(
            file:  "24-cared-for-casting-every-care-1-peter-5-6_7",
            title: "Cared For / Casting Every Care",
            verse: "1 Peter 5:6-7"
        ),
        female: .init(
            file:  "24-cared-for-casting-every-care-1-peter-5-6_7",
            title: "Cared For / Casting Every Care",
            verse: "1 Peter 5:6-7"
        )
    ),
    .init(  // 25
        male: .init(
            file:  "25-blessed-with-every-spiritual-blessing-ephesians-1-3_6",
            title: "Blessed with Every Spiritual Blessing",
            verse: "Ephesians 1:3-6"
        ),
        female: .init(
            file:  "25-blessed-with-every-spiritual-blessing-ephesians-1-3_6",
            title: "Blessed with Every Spiritual Blessing",
            verse: "Ephesians 1:3-6"
        )
    ),
    .init(  // 26
        male: .init(
            file:  "26-given-wisdom-and-spiritual-revelation-ephesians-1-15_22",
            title: "Given Wisdom & Spiritual Revelation",
            verse: "Ephesians 1:15-22"
        ),
        female: .init(
            file:  "26-given-wisdom-and-spiritual-revelation-ephesians-1-17_22",
            title: "Given Wisdom & Spiritual Revelation",
            verse: "Ephesians 1:17-22"
        )
    ),
    .init(  // 27
        male: .init(
            file:  "27-heir-of-god-romans-8-15_17",
            title: "Heir of God",
            verse: "Romans 8:15-17"
        ),
        female: .init(
            file:  "27-heir-of-god-romans-8-15_17",
            title: "Heir of God",
            verse: "Romans 8:15-17"
        )
    ),
    .init(  // 28
        male: .init(
            file:  "28-abounding-in-love-1-thessalonians-3-12_13",
            title: "Abounding in Love",
            verse: "1 Thessalonians 3:12-13"
        ),
        female: .init(
            file:  "28-abounding-in-love-1-thessalonians-3-12_13",
            title: "Abounding in Love",
            verse: "1 Thessalonians 3:12-13"
        )
    ),
    .init(  // 29
        male: .init(
            file:  "29-being-made-perfect-hebrews-13-20_21",
            title: "Being Made Perfect",
            verse: "Hebrews 13:20-21"
        ),
        female: .init(
            file:  "29-being-made-perfect-hebrews-13-20_21",
            title: "Being Made Perfect",
            verse: "Hebrews 13:20-21"
        )
    ),
    .init(  // 30
        male: .init(
            file:  "30-showing-the-praise-of-god-psalm-51-15",
            title: "Showing the Praise of God",
            verse: "Psalm 51:15"
        ),
        female: .init(
            file:  "30-showing-the-praise-of-god-psalm-51-15",
            title: "Showing the Praise of God",
            verse: "Psalm 51:15"
        )
    ),
]

/// The 2nd-person sequence. It opens "Led by the Spirit of God" at 21, so from
/// there on its numbering runs one ahead of the 1st-person sequence — the two
/// lists are deliberately not row-aligned. The male cut ends at 26; the final
/// four were never recorded.
private let secondPersonTracks: [AffirmationTrack] = [
    .init(  // 01
        male: .init(
            file:  "01-reigning-in-life-romans-5-17",
            title: "Reigning in Life",
            verse: "Romans 5:17"
        ),
        female: .init(
            file:  "01-reigning-in-life-romans-5-17",
            title: "Reigning in Life",
            verse: "Romans 5:17"
        )
    ),
    .init(  // 02
        male: .init(
            file:  "02-eternal-perspective-2-corinthians-4-18",
            title: "Eternal Perspective",
            verse: "2 Corinthians 4:18"
        ),
        female: .init(
            file:  "02-eternal-perspective-2-corinthians-4-18",
            title: "Eternal Perspective",
            verse: "2 Corinthians 4:18"
        )
    ),
    .init(  // 03
        male: .init(
            file:  "03-walking-by-faith-2-corinthians-5-7",
            title: "Walking by Faith",
            verse: "2 Corinthians 5:7"
        ),
        female: .init(
            file:  "03-walking-by-faith-2-corinthians-5-7",
            title: "Walking by Faith",
            verse: "2 Corinthians 5:7"
        )
    ),
    .init(  // 04
        male: .init(
            file:  "04-casting-down-imaginations-2-corinthians-10-4_5",
            title: "Casting Down Imaginations",
            verse: "2 Corinthians 10:4-5"
        ),
        female: .init(
            file:  "04-casting-down-imaginations-2-corinthians-10-4_5",
            title: "Casting Down Imaginations",
            verse: "2 Corinthians 10:4-5"
        )
    ),
    .init(  // 05
        male: .init(
            file:  "05-righteousness-of-god-2-corinthians-5-21",
            title: "Righteousness of God",
            verse: "2 Corinthians 5:21"
        ),
        female: .init(
            file:  "05-righteousness-of-god-2-corinthians-5-21",
            title: "Righteousness of God",
            verse: "2 Corinthians 5:21"
        )
    ),
    .init(  // 06
        male: .init(
            file:  "06-rooted-and-grounded-in-love-ephesians-3-14_19",
            title: "Rooted and Grounded in Love",
            verse: "Ephesians 3:14-19"
        ),
        female: .init(
            file:  "06-rooted-and-grounded-in-love-ephesians-3-14_19",
            title: "Rooted and Grounded in Love",
            verse: "Ephesians 3:14-19"
        )
    ),
    .init(  // 07
        male: .init(
            file:  "07-gods-masterpiece-ephesians-2-10",
            title: "God's Masterpiece",
            verse: "Ephesians 2:10"
        ),
        female: .init(
            file:  "07-gods-masterpiece-ephesians-2-10",
            title: "God's Masterpiece",
            verse: "Ephesians 2:10"
        )
    ),
    .init(  // 08
        male: .init(
            file:  "08-partaker-of-gods-divine-nature-2-peter-1-2_4",
            title: "Partaker of God's Divine Nature",
            verse: "2 Peter 1:2-4"
        ),
        female: .init(
            file:  "08-partaker-of-gods-divine-nature-2-peter-1-2_4",
            title: "Partaker of God's Divine Nature",
            verse: "2 Peter 1:2-4"
        )
    ),
    .init(  // 09
        male: .init(
            file:  "09-prosperous-and-in-good-health-3-john-1-2",
            title: "Prosperous and in Good Health",
            verse: "3 John 1:2"
        ),
        female: .init(
            file:  "09-prosperous-and-in-good-health-3-john-1-2",
            title: "Prosperous and in Good Health",
            verse: "3 John 1:2"
        )
    ),
    .init(  // 10
        male: .init(
            file:  "10-transformed-with-a-renewed-mind-romans-12-2",
            title: "Transformed with a Renewed Mind",
            verse: "Romans 12:2"
        ),
        female: .init(
            file:  "10-transformed-with-a-renewed-mind-romans-12-2",
            title: "Transformed with a Renewed Mind",
            verse: "Romans 12:2"
        )
    ),
    .init(  // 11
        male: .init(
            file:  "11-healed-1-peter-2-21_24",
            title: "Healed",
            verse: "1 Peter 2:21-24"
        ),
        female: .init(
            file:  "11-healed-1-peter-2-21_24",
            title: "Healed",
            verse: "1 Peter 2:21-24"
        )
    ),
    .init(  // 12
        male: .init(
            file:  "12-conqueror-romans-8-37_39",
            title: "Conqueror",
            verse: "Romans 8:37-39"
        ),
        female: .init(
            file:  "12-conqueror-romans-8-37_39",
            title: "Conqueror",
            verse: "Romans 8:37-39"
        )
    ),
    .init(  // 13
        male: .init(
            file:  "13-salt-of-the-earth-and-light-of-the-world-matthew-5-13_16",
            title: "Salt of the Earth & Light of the World",
            verse: "Matthew 5:13-16"
        ),
        female: .init(
            file:  "13-salt-of-the-earth-and-light-of-the-world-matthew-5-13_16",
            title: "Salt of the Earth & Light of the World",
            verse: "Matthew 5:13-16"
        )
    ),
    .init(  // 14
        male: .init(
            file:  "14-complete-colossians-2-9_10",
            title: "Complete",
            verse: "Colossians 2:9-10"
        ),
        female: .init(
            file:  "14-complete-colossians-2-9_10",
            title: "Complete",
            verse: "Colossians 2:9-10"
        )
    ),
    .init(  // 15
        male: .init(
            file:  "15-strong-ephesians-6-10_20",
            title: "Strong",
            verse: "Ephesians 6:10-20"
        ),
        female: .init(
            file:  "15-strong-ephesians-6-10_20",
            title: "Strong",
            verse: "Ephesians 6:10-20"
        )
    ),
    .init(  // 16
        male: .init(
            file:  "16-quenching-all-fiery-darts-ephesians-6-16",
            title: "Quenching All Fiery Darts",
            verse: "Ephesians 6:16"
        ),
        female: .init(
            file:  "16-quenching-all-fiery-darts-ephesians-6-16",
            title: "Quenching All Fiery Darts",
            verse: "Ephesians 6:16"
        )
    ),
    .init(  // 17
        male: .init(
            file:  "17-meditating-on-the-words-of-god-joshua-1-7_9",
            title: "Meditating on the Words of God",
            verse: "Joshua 1:7-9"
        ),
        female: .init(
            file:  "17-meditating-on-the-words-of-god-joshua-1-7_9",
            title: "Meditating on the Words of God",
            verse: "Joshua 1:7-9"
        )
    ),
    .init(  // 18
        male: .init(
            file:  "18-strong-and-courageous-joshua-1-9",
            title: "Strong & Courageous",
            verse: "Joshua 1:9"
        ),
        female: .init(
            file:  "18-strong-and-courageous-joshua-1-9",
            title: "Strong & Courageous",
            verse: "Joshua 1:9"
        )
    ),
    .init(  // 19
        male: .init(
            file:  "19-flourishing-and-prosperous-psalm-1-1_3",
            title: "Flourishing & Prosperous",
            verse: "Psalm 1:1-3"
        ),
        female: .init(
            file:  "19-flourishing-and-prosperous-psalm-1-1_3",
            title: "Flourishing & Prosperous",
            verse: "Psalm 1:1-3"
        )
    ),
    .init(  // 20
        male: .init(
            file:  "20-temple-of-the-holy-ghost-1-corinthians-6-19_20",
            title: "Temple of the Holy Ghost",
            verse: "1 Corinthians 6:19-20"
        ),
        female: .init(
            file:  "20-temple-of-the-holy-ghost-1-corinthians-6-19_20",
            title: "Temple of the Holy Ghost",
            verse: "1 Corinthians 6:19-20"
        )
    ),
    .init(  // 21
        male: .init(
            file:  "21-led-by-the-spirit-of-god-romans-8-14",
            title: "Led by the Spirit of God",
            verse: "Romans 8:14"
        ),
        female: .init(
            file:  "21-led-by-the-spirit-of-god-romans-8-14",
            title: "Led by the Spirit of God",
            verse: "Romans 8:14"
        )
    ),
    .init(  // 22
        male: .init(
            file:  "22-child-of-god-romans-8-14",
            title: "Child of God",
            verse: "Romans 8:14"
        ),
        female: .init(
            file:  "22-child-of-god-romans-8-14",
            title: "Child of God",
            verse: "Romans 8:14"
        )
    ),
    .init(  // 23
        male: .init(
            file:  "23-spiritually-minded-romans-8-1_6",
            title: "Spiritually Minded",
            verse: "Romans 8:1-6"
        ),
        female: .init(
            file:  "23-spiritually-minded-romans-8-1_6",
            title: "Spiritually Minded",
            verse: "Romans 8:1-6"
        )
    ),
    .init(  // 24
        male: .init(
            file:  "24-receiving-every-need-met-philippians-4-19",
            title: "Receiving Every Need Met",
            verse: "Philippians 4:19"
        ),
        female: .init(
            file:  "24-receiving-every-need-met-philippians-4-19",
            title: "Receiving Every Need Met",
            verse: "Philippians 4:19"
        )
    ),
    .init(  // 25
        male: .init(
            file:  "25-cared-for-casting-every-care-1-peter-5-6_7",
            title: "Cared For / Casting Every Care",
            verse: "1 Peter 5:6-7"
        ),
        female: .init(
            file:  "25-cared-for-casting-every-care-1-peter-5-6_7",
            title: "Cared For / Casting Every Care",
            verse: "1 Peter 5:6-7"
        )
    ),
    .init(  // 26
        male: .init(
            file:  "26-blessed-with-every-spiritual-blessing-ephesians-1-3_22",
            title: "Blessed with Every Spiritual Blessing",
            verse: "Ephesians 1:3-22"
        ),
        female: .init(
            file:  "26-blessed-with-every-spiritual-blessing-ephesians-1-15_22",
            title: "Blessed with Every Spiritual Blessing",
            verse: "Ephesians 1:15-22"
        )
    ),
    .init(  // 27
        male: nil,
        female: .init(
            file:  "27-heir-of-god-romans-8-15_17",
            title: "Heir of God",
            verse: "Romans 8:15-17"
        )
    ),
    .init(  // 28
        male: nil,
        female: .init(
            file:  "28-abounding-in-love-1-thessalonians-3-12_13",
            title: "Abounding in Love",
            verse: "1 Thessalonians 3:12-13"
        )
    ),
    .init(  // 29
        male: nil,
        female: .init(
            file:  "29-being-made-perfect-hebrews-13-20_21",
            title: "Being Made Perfect",
            verse: "Hebrews 13:20-21"
        )
    ),
    .init(  // 30
        male: nil,
        female: .init(
            file:  "30-showing-the-praise-of-god-psalm-51-15",
            title: "Showing the Praise of God",
            verse: "Psalm 51:15"
        )
    ),
]


// MARK: – As a Child of a King

/// Both voices and both person-forms share one sequence; only the folder differs.
private let childOfAKingRecordings: [VoiceRecording] = [
    .init(file: "01-fully-known-1-corinthians-13-12-psalm-139-zephaniah-3-17", title: "Fully Known", verse: "1 Corinthians 13:12, Psalm 139, Zephaniah 3:17"),
    .init(file: "02-highly-favored-psalm-5-12-psalm-84-11-john-1-12-luke-12-32", title: "Highly Favored", verse: "Psalm 5:12, Psalm 84:11, John 1:12, Luke 12:32"),
    .init(file: "03-royal-heir-of-yahweh-galatians-4-6-7-1-peter-2-9-romans-8-16-17", title: "Royal Heir of Yahweh", verse: "Galatians 4:6-7, 1 Peter 2:9, Romans 8:16-17"),
    .init(file: "04-the-head-not-the-tail-deuteronomy-28-9-14", title: "The Head, not the Tail", verse: "Deuteronomy 28:9-14"),
    .init(file: "05-filled-with-wisdom-colossians-1-9", title: "Filled with Wisdom", verse: "Colossians 1:9"),
    .init(file: "06-knowledge-of-gods-will-colossians-1-9", title: "Knowledge of God’s Will", verse: "Colossians 1:9"),
    .init(file: "07-yahweh-wants-to-prosper-you-psalm-35-27-romans-8-32", title: "Yahweh Wants to Prosper You", verse: "Psalm 35:27, Romans 8:32"),
    .init(file: "08-its-yahwehs-delight-to-prosper-you-deuteronomy-28-18-psalm-35-27-proverbs-8-12-21", title: "It’s Yahweh’s Delight to Prosper You", verse: "Deuteronomy 28:18, Psalm 35:27, Proverbs 8:12-21"),
    .init(file: "09-guided-by-the-spirit-of-god-psalm-37-23-proverbs-3-5", title: "Guided by the Spirit of God", verse: "Psalm 37:23, Proverbs 3:5"),
    .init(file: "10-given-everything-you-need-2-peter-1-3-4-numbers-13-30", title: "Given Everything You Need", verse: "2 Peter 1:3-4, Numbers 13:30"),
    .init(file: "11-blessings-of-yahweh-chase-you-down-deuteronomy-28-2", title: "Blessings of Yahweh Chase You Down", verse: "Deuteronomy 28:2"),
    .init(file: "12-given-unto-you-liberally-luke-6-38", title: "Given Unto You Liberally", verse: "Luke 6:38"),
    .init(file: "13-blessed-with-overflow-malachi-3-10", title: "Blessed with Overflow", verse: "Malachi 3:10"),
    .init(file: "14-unstoppable-success-malachi-3-11", title: "Unstoppable Success", verse: "Malachi 3:11"),
    .init(file: "15-abundance-and-prosperity-proverbs-3-9-10", title: "Abundance & Prosperity", verse: "Proverbs 3:9-10"),
    .init(file: "16-flourishing-and-prosperous-psalm-1-1-3", title: "Flourishing & Prosperous", verse: "Psalm 1:1-3"),
    .init(file: "17-the-blessing-of-yahweh-makes-you-rich-proverbs-10-22", title: "The Blessing of Yahweh Makes You Rich", verse: "Proverbs 10:22"),
    .init(file: "18-everything-turned-for-good-romans-8-28-genesis-50-20", title: "Everything Turned for Good", verse: "Romans 8:28, Genesis 50:20"),
    .init(file: "19-favor-comes-to-you-2-corinthians-9-8", title: "Favor Comes to You", verse: "2 Corinthians 9:8"),
    .init(file: "20-god-blesses-the-work-of-your-hands-deuteronomy-28-12", title: "God Blesses the Work of Your Hands", verse: "Deuteronomy 28:12"),
    .init(file: "21-your-mind-is-renewed-ephesians-4-23-romans-12-2", title: "Your Mind is Renewed", verse: "Ephesians 4:23, Romans 12:2"),
    .init(file: "22-delivered-colossians-1-13-14", title: "Delivered", verse: "Colossians 1:13-14"),
    .init(file: "23-supernatural-creativity-to-prosper-genesis-41-37-49-exodus-31-1-3", title: "Supernatural Creativity to Prosper", verse: "Genesis 41:37-49, Exodus 31:1-3"),
    .init(file: "24-success-proverbs-16-3", title: "Success", verse: "Proverbs 16:3"),
    .init(file: "25-all-your-needs-are-met-philippians-4-19", title: "All Your Needs are Met", verse: "Philippians 4:19"),
    .init(file: "26-no-good-thing-is-withheld-psalm-84-11-12", title: "No Good Thing is Withheld", verse: "Psalm 84:11-12"),
    .init(file: "27-reigning-in-life-romans-5-17-romans-8-17", title: "Reigning in Life", verse: "Romans 5:17, Romans 8:17"),
    .init(file: "28-god-delights-in-your-prosperity-psalm-35-7-galatians-3-14", title: "God Delights in Your Prosperity", verse: "Psalm 35:7, Galatians 3:14"),
    .init(file: "29-chosen-by-yahweh-deuteronomy-26-18-19-1-peter-2-9", title: "Chosen by Yahweh", verse: "Deuteronomy 26:18-19, 1 Peter 2:9"),
    .init(file: "30-nothing-is-too-hard-for-you-isaiah-41-10-philippians-4-13", title: "Nothing is too Hard for You", verse: "Isaiah 41:10, Philippians 4:13"),
    .init(file: "31-influence-peace-luke-10-5-6-romans-12-21-romans-15-13-ephesians-4-2-3", title: "Influence Peace", verse: "Luke 10:5-6, Romans 12:21, Romans 15:13, Ephesians 4:2-3"),
    .init(file: "32-humble-1-peter-5-5-ephesians-2-8-9-philippians-2-3-8", title: "Humble", verse: "1 Peter 5:5, Ephesians 2:8-9, Philippians 2:3-8"),
    .init(file: "33-born-to-win-matthew-5-39-47-1-john-5-4-1-corinthians-15-57-romans-8-37-luke-10-19", title: "Born to Win", verse: "Matthew 5:39-47, 1 John 5:4, 1 Corinthians 15:57, Romans 8:37, Luke 10:19"),
    .init(file: "34-fully-grateful-1-thessalonians-5-18-philippians-4-6", title: "Fully Grateful", verse: "1 Thessalonians 5:18, Philippians 4:6"),
    .init(file: "35-defend-the-defenseless-proverbs-31-8-9-isaiah-1-17-psalm-82-3", title: "Defend the Defenseless", verse: "Proverbs 31:8-9, Isaiah 1:17, Psalm 82:3"),
    .init(file: "36-rise-to-the-occasion-joshua-1-9-galatians-6-9", title: "Rise to the Occasion", verse: "Joshua 1:9, Galatians 6:9"),
    .init(file: "37-god-provides-the-power-proverbs-16-9-proverbs-21-31-zechariah-4-6-isaiah-40-29", title: "God Provides the Power", verse: "Proverbs 16:9, Proverbs 21:31, Zechariah 4:6, Isaiah 40:29"),
    .init(file: "38-flow-in-submission-the-spirit-proverbs-3-5-6-galatians-5-25-proverbs-4-11-12-proverbs-16-3-1-samuel-18-14", title: "Flow: in Submission the Spirit", verse: "Proverbs 3:5-6, Galatians 5:25, Proverbs 4:11-12, Proverbs 16:3, 1 Samuel 18:14"),
    .init(file: "39-power-in-vulnerability-2-corinthians-13-4-james-5-16-philippians-2-5-9", title: "Power in Vulnerability", verse: "2 Corinthians 13:4, James 5:16, Philippians 2:5-9"),
    .init(file: "40-finish-strong-hebrews-12-1", title: "Finish Strong", verse: "Hebrews 12:1"),
    .init(file: "41-confident-jeremiah-17-7-8-jeremiah-9-23-24-1-corinthians-1-30-31-philippians-3-3", title: "Confident", verse: "Jeremiah 17:7-8, Jeremiah 9:23-24, 1 Corinthians 1:30-31, Philippians 3:3"),
    .init(file: "42-resting-in-peace-joy-and-confidence-isaiah-55-12-psalm-4-8-psalm-29-11-psalm-119-165", title: "Resting in Peace, Joy, & Confidence", verse: "Isaiah 55:12, Psalm 4:8, Psalm 29:11, Psalm 119:165"),
    .init(file: "43-radiant-psalm-34-4-5", title: "Radiant", verse: "Psalm 34:4-5"),
    .init(file: "44-thankful-in-advance-mark-11-24-philippians-4-6-7-john-11-41", title: "Thankful in Advance", verse: "Mark 11:24, Philippians 4:6-7, John 11:41"),
    .init(file: "45-claimed-by-yahweh-deuteronomy-28-1-13", title: "Claimed by Yahweh", verse: "Deuteronomy 28:1-13"),
    .init(file: "46-abundance-from-yahweh-proverbs-3-9-10", title: "Abundance from Yahweh", verse: "Proverbs 3:9-10"),
    .init(file: "47-flourishing-and-prosperous-psalm-1-1-3", title: "Flourishing & Prosperous", verse: "Psalm 1:1-3"),
    .init(file: "48-blessing-follows-you-deuteronomy-28-1-13", title: "Blessing Follows You", verse: "Deuteronomy 28:1-13"),
    .init(file: "49-above-not-beneath-deuteronomy-28-13", title: "Above, Not Beneath", verse: "Deuteronomy 28:13"),
    .init(file: "50-child-of-god-deuteronomy-28-13", title: "Child of God", verse: "Deuteronomy 28:13"),
]


// MARK: – Healing frequency albums

struct HealingAlbum: Identifiable, Hashable {
    let folder: String
    let title: String
    let subtitle: String
    let imageName: String
    let category: Track.Category
    let recordings: [VoiceRecording]

    var id: String { folder }

    static func == (lhs: HealingAlbum, rhs: HealingAlbum) -> Bool { lhs.folder == rhs.folder }
    func hash(into hasher: inout Hasher) { hasher.combine(folder) }

    static let all: [HealingAlbum] = [
        .init(
            folder: "ocean-and-444hz-piano",
            title: "Ocean & 444Hz Piano",
            subtitle: "Ocean waves with 444Hz piano",
            imageName: "healing-album-ocean-444hz",
            category: .ocean,
            recordings: [
                .init(file: "peace-be-still", title: "Peace, Be Still", verse: ""),
            ]
        ),
        .init(
            folder: "nature-and-432hz-piano-vol-1",
            title: "Nature & 432Hz Piano, Vol. 1",
            subtitle: "Nature sounds with 432Hz piano",
            imageName: "healing-album-nature-432hz-vol-1",
            category: .forest,
            recordings: [
                .init(file: "01-heart-and-hands", title: "Heart & Hands", verse: ""),
                .init(file: "02-life-gate", title: "Life Gate", verse: ""),
                .init(file: "03-awakening", title: "Awakening", verse: ""),
                .init(file: "04-aura-cleansing", title: "Aura Cleansing", verse: ""),
            ]
        ),
        .init(
            folder: "nature-and-432hz-piano-vol-2",
            title: "Nature & 432Hz Piano, Vol. 2",
            subtitle: "Nature sounds with 432Hz piano",
            imageName: "healing-album-nature-432hz-vol-2",
            category: .forest,
            recordings: [
                .init(file: "01-refuge", title: "Refuge", verse: ""),
                .init(file: "02-strength", title: "Strength", verse: ""),
                .init(file: "03-rest-and-release", title: "Rest & Release", verse: ""),
            ]
        ),
    ]
}
