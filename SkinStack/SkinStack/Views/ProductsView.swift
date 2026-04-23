import SwiftUI
import SwiftData
import PhotosUI

struct ProductsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SkinProduct.addedDate) private var products: [SkinProduct]
    @Environment(StoreManager.self) private var storeManager
    @Environment(ConflictDetectionEngine.self) private var conflictEngine
    @State private var showingAddProduct = false
    @State private var showingPaywall = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(products) { product in
                        NavigationLink {
                            ProductDetailView(product: product)
                        } label: {
                            ProductRow(product: product)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Color.skinStackBackground)
            .navigationTitle("My Products")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if products.count >= 3 && !storeManager.isPro {
                            showingPaywall = true
                        } else {
                            showingAddProduct = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .overlay {
                if products.isEmpty {
                    ContentUnavailableView(
                        "No Products",
                        systemImage: "bottle.fill",
                        description: Text("Tap + to add your first skincare product")
                    )
                }
            }
            .sheet(isPresented: $showingAddProduct) {
                AddProductView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

struct ProductRow: View {
    let product: SkinProduct
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: product.category.icon)
                .font(.title2)
                .foregroundStyle(Color.skinStackPrimary)
                .frame(width: 44, height: 44)
                .background(Color.skinStackPrimary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                if !product.brand.isEmpty {
                    Text(product.brand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 8) {
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
                    Text(product.category.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.skinStackSecondary.opacity(0.15))
                        .foregroundStyle(Color.skinStackSecondary)
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

#Preview {
    ProductsView()
        .modelContainer(for: [SkinProduct.self, SkinJournalEntry.self], inMemory: true)
        .environment(StoreManager())
        .environment(ConflictDetectionEngine())
}
