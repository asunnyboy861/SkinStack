import Foundation
import SwiftData

@Model
final class SkinProduct {
    var id: UUID
    var name: String
    var brand: String
    var categoryRaw: String
    var textureRaw: String
    var ingredients: [String]
    var isAM: Bool
    var isPM: Bool
    var customOrder: Int
    var notes: String
    var addedDate: Date
    var isFavorite: Bool
    
    var category: ProductCategory {
        get { ProductCategory(rawValue: categoryRaw) ?? .custom }
        set { categoryRaw = newValue.rawValue }
    }
    
    var texture: ProductTexture {
        get { ProductTexture(rawValue: textureRaw) ?? .lotion }
        set { textureRaw = newValue.rawValue }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        brand: String = "",
        category: ProductCategory = .custom,
        texture: ProductTexture = .lotion,
        ingredients: [String] = [],
        isAM: Bool = true,
        isPM: Bool = true,
        customOrder: Int = 0,
        notes: String = "",
        addedDate: Date = Date(),
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.categoryRaw = category.rawValue
        self.textureRaw = texture.rawValue
        self.ingredients = ingredients
        self.isAM = isAM
        self.isPM = isPM
        self.customOrder = customOrder
        self.notes = notes
        self.addedDate = addedDate
        self.isFavorite = isFavorite
    }
}
