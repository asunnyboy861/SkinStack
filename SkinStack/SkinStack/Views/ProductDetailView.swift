import SwiftUI
import SwiftData

struct ProductDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreManager.self) private var storeManager
    @Environment(ConflictDetectionEngine.self) private var conflictEngine
    @Query private var allProducts: [SkinProduct]
    
    let product: SkinProduct
    @State private var showingEdit = false
    @State private var showingDeleteAlert = false
    
    private var conflicts: [ConflictResult] {
        conflictEngine.detectConflicts(for: product, against: allProducts.filter { $0.id != product.id }, isPro: storeManager.isPro)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                productHeader
                ingredientSection
                if !conflicts.isEmpty {
                    conflictSection
                }
                if !product.notes.isEmpty {
                    notesSection
                }
            }
            .padding()
        }
        .background(Color.skinStackBackground)
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingEdit = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Delete Product?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                modelContext.delete(product)
                dismiss()
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditProductView(product: product)
        }
    }
    
    private var productHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: product.category.icon)
                    .font(.title)
                    .foregroundStyle(Color.skinStackPrimary)
                VStack(alignment: .leading) {
                    Text(product.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    if !product.brand.isEmpty {
                        Text(product.brand)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            HStack(spacing: 12) {
                Label(product.category.rawValue, systemImage: product.category.icon)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.skinStackPrimary.opacity(0.12))
                    .foregroundStyle(Color.skinStackPrimary)
                    .clipShape(Capsule())
                
                Label(product.texture.rawValue, systemImage: "drop.fill")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.skinStackSecondary.opacity(0.12))
                    .foregroundStyle(Color.skinStackSecondary)
                    .clipShape(Capsule())
                
                if product.isAM {
                    Text("AM")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.15))
                        .foregroundStyle(.orange)
                        .clipShape(Capsule())
                }
                if product.isPM {
                    Text("PM")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.indigo.opacity(0.15))
                        .foregroundStyle(.indigo)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var ingredientSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ingredients")
                .font(.headline)
            
            if product.ingredients.isEmpty {
                Text("No ingredients listed")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(product.ingredients, id: \.self) { ingredient in
                        Text(ingredient)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.skinStackSecondaryLight.opacity(0.3))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var conflictSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Conflicts")
                .font(.headline)
            
            ForEach(conflicts) { conflict in
                ConflictBadge(conflict: conflict)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
            Text(product.notes)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }
        
        return (CGSize(width: maxX, height: currentY + rowHeight), positions)
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(product: SkinProduct(name: "Test Serum", brand: "Test Brand", category: .serum, ingredients: ["Niacinamide", "Hyaluronic Acid"]))
    }
    .modelContainer(for: [SkinProduct.self, SkinJournalEntry.self], inMemory: true)
    .environment(StoreManager())
    .environment(ConflictDetectionEngine())
}
