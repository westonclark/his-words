import SwiftUI

struct Track: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let category: Category
    let duration: TimeInterval
    let streamURL: String
    let isPremium: Bool

    enum Category: String, CaseIterable, Codable, Hashable {
        case rain, forest, ocean, wind, fire, affirmations

        var displayName: String {
            switch self {
            case .affirmations: return "Affirmations"
            default: return rawValue.capitalized
            }
        }

        var icon: String {
            switch self {
            case .rain:         return "cloud.rain.fill"
            case .forest:       return "leaf.fill"
            case .ocean:        return "water.waves"
            case .wind:         return "wind"
            case .fire:         return "flame.fill"
            case .affirmations: return "text.bubble.fill"
            }
        }

        var gradient: [Color] {
            switch self {
            case .rain:         return [Color(red: 0.18, green: 0.28, blue: 0.50), Color(red: 0.07, green: 0.11, blue: 0.28)]
            case .forest:       return [Color(red: 0.07, green: 0.28, blue: 0.14), Color(red: 0.04, green: 0.13, blue: 0.08)]
            case .ocean:        return [Color(red: 0.04, green: 0.20, blue: 0.42), Color(red: 0.02, green: 0.09, blue: 0.24)]
            case .wind:         return [Color(red: 0.24, green: 0.27, blue: 0.38), Color(red: 0.11, green: 0.13, blue: 0.22)]
            case .fire:         return [Color(red: 0.40, green: 0.17, blue: 0.04), Color(red: 0.22, green: 0.06, blue: 0.02)]
            case .affirmations: return [Color(red: 0.35, green: 0.22, blue: 0.52), Color(red: 0.18, green: 0.10, blue: 0.30)]
            }
        }
    }
}
