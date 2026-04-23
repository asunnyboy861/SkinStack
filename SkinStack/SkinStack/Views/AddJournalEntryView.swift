import SwiftUI
import SwiftData

struct AddJournalEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var products: [SkinProduct]
    
    @State private var condition: SkinCondition = .okay
    @State private var selectedConcerns: Set<SkinConcern> = []
    @State private var notes = ""
    @State private var selectedProductIDs: Set<UUID> = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section("How's your skin today?") {
                    Picker("Condition", selection: $condition) {
                        ForEach(SkinCondition.allCases, id: \.self) { c in
                            Text("\(c.emoji) \(c.label)").tag(c)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Concerns") {
                    ForEach(SkinConcern.allCases, id: \.self) { concern in
                        Toggle(concern.rawValue, isOn: Binding(
                            get: { selectedConcerns.contains(concern) },
                            set: { isSelected in
                                if isSelected {
                                    selectedConcerns.insert(concern)
                                } else {
                                    selectedConcerns.remove(concern)
                                }
                            }
                        ))
                    }
                }
                
                Section("Products Used Today") {
                    ForEach(products) { product in
                        Toggle(product.name, isOn: Binding(
                            get: { selectedProductIDs.contains(product.id) },
                            set: { isSelected in
                                if isSelected {
                                    selectedProductIDs.insert(product.id)
                                } else {
                                    selectedProductIDs.remove(product.id)
                                }
                            }
                        ))
                    }
                }
                
                Section("Notes") {
                    TextField("How does your skin feel?", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                }
            }
        }
    }
    
    private func saveEntry() {
        let productNames = products
            .filter { selectedProductIDs.contains($0.id) }
            .map(\.name)
        
        let entry = SkinJournalEntry(
            condition: condition,
            concerns: selectedConcerns.map(\.rawValue),
            notes: notes,
            routineProductNames: productNames
        )
        modelContext.insert(entry)
        dismiss()
    }
}

#Preview {
    AddJournalEntryView()
        .modelContainer(for: [SkinProduct.self, SkinJournalEntry.self], inMemory: true)
}
