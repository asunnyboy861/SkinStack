import SwiftUI
import SwiftData

struct RoutineView: View {
    @Query(sort: \SkinProduct.addedDate) private var products: [SkinProduct]
    @Environment(StoreManager.self) private var storeManager
    @Environment(ConflictDetectionEngine.self) private var conflictEngine
    @State private var selectedTime: TimeOfDay = .am
    @State private var showingTimer = false
    
    private var routineSteps: [RoutineStep] {
        conflictEngine.generateRoutine(products: products, timeOfDay: selectedTime, isPro: storeManager.isPro)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    timePicker
                    
                    if routineSteps.isEmpty {
                        emptyState
                    } else {
                        conflictSummary
                        routineList
                    }
                }
                .padding()
            }
            .background(Color.skinStackBackground)
            .navigationTitle("My Routine")
            .toolbar {
                if !routineSteps.isEmpty && storeManager.isPro {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingTimer = true
                        } label: {
                            Image(systemName: "timer")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingTimer) {
                if !routineSteps.isEmpty {
                    WaitTimeTimerView(steps: routineSteps)
                }
            }
        }
    }
    
    private var timePicker: some View {
        Picker("Time of Day", selection: $selectedTime) {
            ForEach(TimeOfDay.allCases, id: \.self) { time in
                Text(time.rawValue).tag(time)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bottle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.skinStackPrimary.opacity(0.5))
            Text("No products yet")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Add your skincare products to build your routine")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 80)
    }
    
    private var conflictSummary: some View {
        let conflicts = routineSteps.flatMap { $0.conflictWarnings }
        let avoidCount = conflicts.filter { $0.level == .avoid }.count
        let cautionCount = conflicts.filter { $0.level == .caution }.count
        let synergisticCount = conflicts.filter { $0.level == .synergistic }.count
        
        return Group {
            if avoidCount > 0 || cautionCount > 0 {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Color.skinStackConflict)
                        Text("Conflict Alert")
                            .font(.headline)
                            .foregroundStyle(Color.skinStackConflict)
                        Spacer()
                    }
                    
                    HStack(spacing: 16) {
                        if avoidCount > 0 {
                            Label("\(avoidCount) Avoid", systemImage: "xmark.circle.fill")
                                .foregroundStyle(Color.skinStackConflict)
                                .font(.subheadline)
                        }
                        if cautionCount > 0 {
                            Label("\(cautionCount) Caution", systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color.skinStackCaution)
                                .font(.subheadline)
                        }
                        if synergisticCount > 0 && storeManager.isPro {
                            Label("\(synergisticCount) Synergistic", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(Color.skinStackSafe)
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(Color.skinStackConflict.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if synergisticCount > 0 && storeManager.isPro {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.skinStackSafe)
                        Text("Great Combinations!")
                            .font(.headline)
                            .foregroundStyle(Color.skinStackSafe)
                        Spacer()
                    }
                    Text("\(synergisticCount) synergistic pair\(synergisticCount > 1 ? "s" : "") detected")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color.skinStackSafe.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private var routineList: some View {
        LazyVStack(spacing: 12) {
            ForEach(routineSteps) { step in
                RoutineStepRow(step: step, isPro: storeManager.isPro)
            }
        }
    }
}

struct RoutineStepRow: View {
    let step: RoutineStep
    let isPro: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Step \(step.stepNumber)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.skinStackPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.skinStackPrimary.opacity(0.15))
                    .clipShape(Capsule())
                
                Text(step.product.name)
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: step.product.category.icon)
                    .foregroundStyle(Color.skinStackSecondary)
            }
            
            if !step.product.brand.isEmpty {
                Text(step.product.brand)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if step.hasConflict {
                ForEach(step.conflictWarnings.filter { $0.level == .avoid || $0.level == .caution }) { conflict in
                    ConflictBadge(conflict: conflict)
                }
            }
            
            if let waitTime = step.waitTimeSeconds, isPro {
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundStyle(Color.skinStackSecondary)
                    Text("Wait \(waitTime / 60) min before next step")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 2)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .overlay(
            step.hasConflict
            ? RoundedRectangle(cornerRadius: 12)
                .stroke(Color.skinStackConflict.opacity(0.3), lineWidth: 1)
            : nil
        )
    }
}

struct ConflictBadge: View {
    let conflict: ConflictResult
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: conflict.level.icon)
                .font(.caption2)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(conflict.ingredientA) + \(conflict.ingredientB)")
                    .font(.caption)
                    .fontWeight(.medium)
                Text(conflict.recommendation)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .foregroundStyle(conflict.level == .avoid ? Color.skinStackConflict : Color.skinStackCaution)
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            (conflict.level == .avoid ? Color.skinStackConflict : Color.skinStackCaution).opacity(0.08)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    RoutineView()
        .modelContainer(for: [SkinProduct.self, SkinJournalEntry.self], inMemory: true)
        .environment(StoreManager())
        .environment(ConflictDetectionEngine())
}
