import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(StoreManager.self) private var storeManager
    @Query(sort: \SkinJournalEntry.date, order: .reverse) private var entries: [SkinJournalEntry]
    @State private var showingAddEntry = false
    @State private var showingPaywall = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if storeManager.isPro {
                    if entries.isEmpty {
                        emptyState
                    } else {
                        chartSection
                        entriesList
                    }
                } else {
                    proLockedState
                }
            }
            .background(Color.skinStackBackground)
            .navigationTitle("Skin Journal")
            .toolbar {
                if storeManager.isPro {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingAddEntry = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddJournalEntryView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
    
    private var emptyState: some View {
        ContentUnavailableView(
            "No Entries Yet",
            systemImage: "book.fill",
            description: Text("Track your skin condition daily to see trends")
        )
    }
    
    private var proLockedState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "lock.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.skinStackSecondary)
            Text("Skin Journal is a Pro Feature")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Track your skin condition, see trends, and get personalized insights")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showingPaywall = true
            } label: {
                Text("Upgrade to Pro")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.skinStackPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
            Spacer()
        }
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Skin Trend")
                .font(.headline)
                .padding(.horizontal)
            
            SkinTrendChart(entries: Array(entries.prefix(30)))
                .frame(height: 200)
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
        }
    }
    
    private var entriesList: some View {
        LazyVStack(spacing: 12) {
            ForEach(entries) { entry in
                JournalEntryRow(entry: entry)
            }
        }
        .padding()
    }
}

struct JournalEntryRow: View {
    let entry: SkinJournalEntry
    
    var body: some View {
        HStack(spacing: 12) {
            Text(entry.condition.emoji)
                .font(.title)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                Text(entry.condition.label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !entry.concerns.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(entry.concerns, id: \.self) { concern in
                            Text(concern)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.skinStackCaution.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

struct SkinTrendChart: View {
    let entries: [SkinJournalEntry]
    
    var body: some View {
        if entries.isEmpty {
            Text("No data yet")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            let sortedEntries = entries.sorted { $0.date < $1.date }
            let maxCondition = 5.0
            
            Path { path in
                guard !sortedEntries.isEmpty else { return }
                let xStep = 200.0 / max(Double(sortedEntries.count - 1), 1)
                
                for (index, entry) in sortedEntries.enumerated() {
                    let x = CGFloat(index) * xStep
                    let y = 200.0 - (Double(entry.conditionRaw) / maxCondition) * 180.0 - 10
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.skinStackPrimary, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            
            ForEach(Array(sortedEntries.enumerated()), id: \.offset) { index, entry in
                let xStep = 200.0 / max(Double(sortedEntries.count - 1), 1)
                let x = CGFloat(index) * xStep
                let y = 200.0 - (Double(entry.conditionRaw) / maxCondition) * 180.0 - 10
                
                Circle()
                    .fill(Color.skinStackPrimary)
                    .frame(width: 6, height: 6)
                    .position(x: x, y: y)
            }
        }
    }
}

#Preview {
    JournalView()
        .modelContainer(for: [SkinProduct.self, SkinJournalEntry.self], inMemory: true)
        .environment(StoreManager())
}
