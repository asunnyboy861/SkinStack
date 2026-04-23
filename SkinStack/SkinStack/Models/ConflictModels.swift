import Foundation

struct ConflictRule: Codable, Identifiable {
    let id: UUID
    let ingredientA: String
    let ingredientB: String
    let level: ConflictLevel
    let reason: String
    let recommendation: String
    
    init(
        id: UUID = UUID(),
        ingredientA: String,
        ingredientB: String,
        level: ConflictLevel,
        reason: String,
        recommendation: String
    ) {
        self.id = id
        self.ingredientA = ingredientA
        self.ingredientB = ingredientB
        self.level = level
        self.reason = reason
        self.recommendation = recommendation
    }
}

enum ConflictLevel: String, Codable, CaseIterable {
    case avoid = "Avoid"
    case caution = "Caution"
    case neutral = "Neutral"
    case synergistic = "Synergistic"
    
    var color: String {
        switch self {
        case .avoid: return "#E85C5C"
        case .caution: return "#F0A840"
        case .neutral: return "#8E8E93"
        case .synergistic: return "#5CC46E"
        }
    }
    
    var icon: String {
        switch self {
        case .avoid: return "xmark.circle.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .neutral: return "minus.circle.fill"
        case .synergistic: return "checkmark.circle.fill"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .avoid: return 0
        case .caution: return 1
        case .neutral: return 2
        case .synergistic: return 3
        }
    }
}

struct ConflictResult: Identifiable {
    let id = UUID()
    let productA: SkinProduct
    let productB: SkinProduct
    let ingredientA: String
    let ingredientB: String
    let level: ConflictLevel
    let reason: String
    let recommendation: String
}
