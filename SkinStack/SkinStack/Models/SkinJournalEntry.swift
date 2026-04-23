import Foundation
import SwiftData

@Model
final class SkinJournalEntry {
    var id: UUID
    var date: Date
    var conditionRaw: Int
    var concerns: [String]
    var notes: String
    var photoData: Data?
    var routineProductNames: [String]
    
    var condition: SkinCondition {
        get { SkinCondition(rawValue: conditionRaw) ?? .okay }
        set { conditionRaw = newValue.rawValue }
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        condition: SkinCondition = .okay,
        concerns: [String] = [],
        notes: String = "",
        photoData: Data? = nil,
        routineProductNames: [String] = []
    ) {
        self.id = id
        self.date = date
        self.conditionRaw = condition.rawValue
        self.concerns = concerns
        self.notes = notes
        self.photoData = photoData
        self.routineProductNames = routineProductNames
    }
}
