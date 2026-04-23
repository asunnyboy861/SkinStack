import Foundation
import SwiftData

enum ProductCategory: String, Codable, CaseIterable {
    case cleanser = "Cleanser"
    case toner = "Toner"
    case essence = "Essence"
    case serum = "Serum"
    case treatment = "Treatment"
    case moisturizer = "Moisturizer"
    case oil = "Face Oil"
    case sunscreen = "Sunscreen"
    case exfoliant = "Exfoliant"
    case mask = "Mask"
    case eyeCream = "Eye Cream"
    case custom = "Custom"
    
    var icon: String {
        switch self {
        case .cleanser: return "drop.fill"
        case .toner: return "spraybottle.fill"
        case .essence: return "flask.fill"
        case .serum: return "eyedropper.fill"
        case .treatment: return "cross.vial.fill"
        case .moisturizer: return "cloud.fill"
        case .oil: return "drop.fill"
        case .sunscreen: return "sun.max.fill"
        case .exfoliant: return "sparkles"
        case .mask: return "face.dashed.fill"
        case .eyeCream: return "eye.fill"
        case .custom: return "square.grid.2x2.fill"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .cleanser: return 1
        case .toner: return 2
        case .essence: return 3
        case .serum: return 4
        case .treatment: return 5
        case .exfoliant: return 5
        case .eyeCream: return 6
        case .moisturizer: return 7
        case .oil: return 8
        case .sunscreen: return 9
        case .mask: return 10
        case .custom: return 11
        }
    }
}

enum ProductTexture: String, Codable, CaseIterable {
    case water = "Water-based"
    case gel = "Gel"
    case lotion = "Lotion"
    case cream = "Cream"
    case oil = "Oil"
    case balm = "Balm"
    case powder = "Powder"
    
    var layerOrder: Int {
        switch self {
        case .water: return 1
        case .gel: return 2
        case .lotion: return 3
        case .cream: return 4
        case .oil: return 5
        case .balm: return 6
        case .powder: return 7
        }
    }
}

enum SkinCondition: Int, Codable, CaseIterable {
    case terrible = 1
    case poor = 2
    case okay = 3
    case good = 4
    case glowing = 5
    
    var emoji: String {
        switch self {
        case .terrible: return "\u{1F61E}"
        case .poor: return "\u{1F610}"
        case .okay: return "\u{1F642}"
        case .good: return "\u{1F60A}"
        case .glowing: return "\u{2728}"
        }
    }
    
    var label: String {
        switch self {
        case .terrible: return "Terrible"
        case .poor: return "Poor"
        case .okay: return "Okay"
        case .good: return "Good"
        case .glowing: return "Glowing!"
        }
    }
}

enum SkinConcern: String, Codable, CaseIterable {
    case breakouts = "Breakouts"
    case dryness = "Dryness"
    case redness = "Redness"
    case oiliness = "Oiliness"
    case dullness = "Dullness"
    case texture = "Uneven Texture"
    case darkSpots = "Dark Spots"
    case fineLines = "Fine Lines"
    case sensitivity = "Sensitivity"
}
