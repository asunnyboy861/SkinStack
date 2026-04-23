import Foundation

@Observable
final class ConflictDetectionEngine {
    private var conflictRules: [ConflictRule] = []
    
    init() {
        loadDefaultRules()
    }
    
    func detectConflicts(between products: [SkinProduct], isPro: Bool) -> [ConflictResult] {
        var results: [ConflictResult] = []
        let maxLevel: ConflictLevel = isPro ? .synergistic : .caution
        
        for i in 0..<products.count {
            for j in (i + 1)..<products.count {
                let productA = products[i]
                let productB = products[j]
                
                for ingredientA in productA.ingredients {
                    for ingredientB in productB.ingredients {
                        if let rule = findRule(ingredientA: ingredientA, ingredientB: ingredientB) {
                            if rule.level.sortOrder <= maxLevel.sortOrder {
                                let result = ConflictResult(
                                    productA: productA,
                                    productB: productB,
                                    ingredientA: ingredientA,
                                    ingredientB: ingredientB,
                                    level: rule.level,
                                    reason: rule.reason,
                                    recommendation: rule.recommendation
                                )
                                results.append(result)
                            }
                        }
                    }
                }
            }
        }
        
        return results.sorted { $0.level.sortOrder < $1.level.sortOrder }
    }
    
    func detectConflicts(for product: SkinProduct, against existing: [SkinProduct], isPro: Bool) -> [ConflictResult] {
        detectConflicts(between: [product] + existing, isPro: isPro)
            .filter { $0.productA.id == product.id || $0.productB.id == product.id }
    }
    
    func generateRoutine(products: [SkinProduct], timeOfDay: TimeOfDay, isPro: Bool) -> [RoutineStep] {
        let filtered = products.filter { timeOfDay == .am ? $0.isAM : $0.isPM }
        let conflicts = detectConflicts(between: filtered, isPro: isPro)
        
        let sorted = filtered.sorted { productA, productB in
            if productA.texture.layerOrder != productB.texture.layerOrder {
                return productA.texture.layerOrder < productB.texture.layerOrder
            }
            if productA.category.sortOrder != productB.category.sortOrder {
                return productA.category.sortOrder < productB.category.sortOrder
            }
            return productA.customOrder < productB.customOrder
        }
        
        return sorted.enumerated().map { index, product in
            let productConflicts = conflicts.filter {
                $0.productA.id == product.id || $0.productB.id == product.id
            }
            
            let waitTime: Int? = isPro ? recommendedWaitTime(for: product, nextProduct: index + 1 < sorted.count ? sorted[index + 1] : nil) : nil
            
            return RoutineStep(
                product: product,
                stepNumber: index + 1,
                waitTimeSeconds: waitTime,
                conflictWarnings: productConflicts
            )
        }
    }
    
    private func findRule(ingredientA: String, ingredientB: String) -> ConflictRule? {
        conflictRules.first { rule in
            (rule.ingredientA.lowercased() == ingredientA.lowercased() && rule.ingredientB.lowercased() == ingredientB.lowercased()) ||
            (rule.ingredientA.lowercased() == ingredientB.lowercased() && rule.ingredientB.lowercased() == ingredientA.lowercased())
        }
    }
    
    private func recommendedWaitTime(for product: SkinProduct, nextProduct: SkinProduct?) -> Int? {
        guard nextProduct != nil else { return nil }
        
        switch product.texture {
        case .water:
            return 60
        case .gel:
            return 90
        case .lotion:
            return 120
        case .cream:
            return 180
        case .oil:
            return 300
        case .balm:
            return 300
        case .powder:
            return 60
        }
    }
    
    private func loadDefaultRules() {
        conflictRules = [
            ConflictRule(ingredientA: "Retinol", ingredientB: "AHA", level: .avoid, reason: "Retinol + AHA causes excessive irritation and compromises skin barrier", recommendation: "Use AHA in AM, Retinol in PM, or alternate nights"),
            ConflictRule(ingredientA: "Retinol", ingredientB: "BHA", level: .caution, reason: "Retinol + BHA may cause dryness and irritation", recommendation: "Start with low concentrations, use on alternate nights"),
            ConflictRule(ingredientA: "Retinol", ingredientB: "Vitamin C", level: .caution, reason: "Different pH requirements may reduce effectiveness", recommendation: "Use Vitamin C in AM, Retinol in PM"),
            ConflictRule(ingredientA: "Retinol", ingredientB: "Benzoyl Peroxide", level: .avoid, reason: "Benzoyl Peroxide oxidizes Retinol, making it ineffective", recommendation: "Use at different times of day or alternate nights"),
            ConflictRule(ingredientA: "Vitamin C", ingredientB: "AHA", level: .caution, reason: "Both are acidic, may cause over-exfoliation", recommendation: "Use on alternate days or different routines"),
            ConflictRule(ingredientA: "Vitamin C", ingredientB: "Niacinamide", level: .neutral, reason: "Myth: they don't cancel each other out, but may cause flushing in sensitive skin", recommendation: "Safe to layer, but patch test first"),
            ConflictRule(ingredientA: "AHA", ingredientB: "BHA", level: .caution, reason: "Double exfoliation may damage skin barrier", recommendation: "Use on alternate days, not in same routine"),
            ConflictRule(ingredientA: "Benzoyl Peroxide", ingredientB: "Vitamin C", level: .avoid, reason: "Benzoyl Peroxide oxidizes Vitamin C, rendering it ineffective", recommendation: "Use Vitamin C in AM, BP in PM"),
            ConflictRule(ingredientA: "Retinol", ingredientB: "Niacinamide", level: .synergistic, reason: "Niacinamide helps reduce retinol irritation and strengthens barrier", recommendation: "Great combo! Apply niacinamide first, then retinol"),
            ConflictRule(ingredientA: "Vitamin C", ingredientB: "Vitamin E", level: .synergistic, reason: "Vitamin C + E double antioxidant protection, more effective together", recommendation: "Apply together for maximum UV protection"),
            ConflictRule(ingredientA: "Hyaluronic Acid", ingredientB: "Retinol", level: .synergistic, reason: "HA hydrates and buffers retinol irritation", recommendation: "Apply HA first to damp skin, then retinol"),
            ConflictRule(ingredientA: "Hyaluronic Acid", ingredientB: "Vitamin C", level: .synergistic, reason: "HA enhances Vitamin C absorption and hydration", recommendation: "Apply Vitamin C first, then HA on top"),
            ConflictRule(ingredientA: "Niacinamide", ingredientB: "Hyaluronic Acid", level: .synergistic, reason: "Both support skin barrier and hydration", recommendation: "Apply niacinamide first, then HA"),
            ConflictRule(ingredientA: "Retinol", ingredientB: "Azeleic Acid", level: .caution, reason: "Both active, may increase irritation", recommendation: "Use on alternate nights"),
            ConflictRule(ingredientA: "AHA", ingredientB: "Retinal", level: .avoid, reason: "AHA + Retinal causes excessive irritation", recommendation: "Use AHA in AM, Retinal in PM"),
            ConflictRule(ingredientA: "Copper Peptides", ingredientB: "Vitamin C", level: .avoid, reason: "Copper peptides oxidize Vitamin C", recommendation: "Use at different times of day"),
            ConflictRule(ingredientA: "Copper Peptides", ingredientB: "Retinol", level: .caution, reason: "May reduce each other's effectiveness", recommendation: "Use on alternate nights"),
            ConflictRule(ingredientA: "Salicylic Acid", ingredientB: "Retinol", level: .caution, reason: "Combined exfoliation may damage barrier", recommendation: "Use SA in AM, Retinol in PM"),
            ConflictRule(ingredientA: "Glycolic Acid", ingredientB: "Retinol", level: .avoid, reason: "Glycolic acid + Retinol = severe irritation risk", recommendation: "Never in same routine, alternate nights"),
            ConflictRule(ingredientA: "Lactic Acid", ingredientB: "Retinol", level: .caution, reason: "Milder AHA but still increases irritation with retinol", recommendation: "Alternate nights recommended"),
        ]
    }
}

enum TimeOfDay: String, CaseIterable {
    case am = "AM"
    case pm = "PM"
}
