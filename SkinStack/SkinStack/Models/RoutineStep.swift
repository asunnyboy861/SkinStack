import Foundation

struct RoutineStep: Identifiable {
    let id = UUID()
    let product: SkinProduct
    let stepNumber: Int
    let waitTimeSeconds: Int?
    let conflictWarnings: [ConflictResult]
    
    var waitTimeMinutes: Int? {
        guard let seconds = waitTimeSeconds else { return nil }
        return seconds / 60
    }
    
    var hasConflict: Bool {
        conflictWarnings.contains { $0.level == .avoid || $0.level == .caution }
    }
}
