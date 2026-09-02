import CryptoKit
import Foundation

private let cdnBase = "https://pub-d6aadca8714e4a51804dc8762b7f9f6d.r2.dev"

/// Everything lives under this prefix in the R2 bucket.
private let audioBase = "audio"

// MARK: – Topic

enum Topic: String, CaseIterable, Identifiable, Hashable {
    case biblicalAffirmations = "biblical-affirmations"
    case healingFrequencies   = "healing-frequencies"
    case childOfAKing = "child-of-a-king"
    case confidence
    case health
    case paulsPrayers = "pauls-prayers"
    case loved

    var id: String { rawValue }

    var title: String {
        switch self {
        case .biblicalAffirmations: return "Biblical Affirmations"
        case .healingFrequencies:   return "Healing Frequencies"
        case .childOfAKing:         return "As a Child of a King"
        case .confidence:           return "Confidence"
        case .health:               return "Health"
        case .paulsPrayers:         return "Paul's Prayers"
        case .loved:                return "Loved"
        }
    }

    var subtitle: String {
        switch self {
        case .biblicalAffirmations: return "Scripture-rooted identity, spoken over you"
        case .healingFrequencies:   return "Solfeggio tones for rest and restoration"
        case .childOfAKing:         return "Coming soon"
        case .confidence:           return "Coming soon"
        case .health:               return "Coming soon"
        case .paulsPrayers:         return "Coming soon"
        case .loved:                return "Coming soon"
        }
    }

    var isAvailable: Bool {
        switch self {
        case .biblicalAffirmations, .healingFrequencies: return true
        case .childOfAKing, .confidence, .health, .paulsPrayers, .loved: return false
        }
    }

    var imageName: String? {
        switch self {
        case .biblicalAffirmations: return "topic-biblical-affirmations"
        case .healingFrequencies:   return Ambience.oceanWaves.imageName
        case .childOfAKing, .confidence, .health, .paulsPrayers, .loved: return nil
        }
    }

    var icon: String {
        switch self {
        case .biblicalAffirmations: return "text.bubble.fill"
        case .healingFrequencies:   return "waveform"
        case .childOfAKing:         return "crown.fill"
        case .confidence:           return "shield.fill"
        case .health:               return "heart.fill"
        case .paulsPrayers:         return "hands.sparkles.fill"
        case .loved:                return "heart.text.square.fill"
        }
    }

    /// Whether the voice / person toggles apply to this topic's audio.
    var hasVoiceOptions: Bool { self == .biblicalAffirmations }

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
                .flatMap(VoiceOption.init(rawValue:)) ?? .male
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
        case .childOfAKing, .confidence, .health, .paulsPrayers, .loved:
            return []
        }
    }

    private static func affirmationTracks(_ context: PlaybackContext) -> [Track] {
        entries(voice: context.voice, person: context.person).map { recording in
            let path = "\(audioBase)/biblical-affirmations/\(context.ambience.rawValue)/\(context.voice.rawValue)/\(context.person.rawValue)/\(recording.file).m4a"
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
