import SwiftUI
import SwiftData

struct EditProductView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreManager.self) private var storeManager
    
    let product: SkinProduct
    
    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var category: ProductCategory = .serum
    @State private var texture: ProductTexture = .lotion
    @State private var isAM: Bool = true
    @State private var isPM: Bool = true
    @State private var ingredients: [String] = []
    @State private var ingredientInput = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Product Info") {
                    TextField("Product Name", text: $name)
                    TextField("Brand", text: $brand)
                    Picker("Category", selection: $category) {
                        ForEach(ProductCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                    Picker("Texture", selection: $texture) {
                        ForEach(ProductTexture.allCases, id: \.self) { tex in
                            Text(tex.rawValue).tag(tex)
                        }
                    }
                }
                
                Section("When to Use") {
                    Toggle("Morning (AM)", isOn: $isAM)
                    Toggle("Night (PM)", isOn: $isPM)
                }
                
                Section {
                    HStack {
                        TextField("Add ingredient", text: $ingredientInput)
                            .onSubmit { addIngredient() }
                        Button("Add", action: addIngredient)
                            .disabled(ingredientInput.isEmpty)
                    }
                    
                    ForEach(ingredients, id: \.self) { ingredient in
                        HStack {
                            Text(ingredient)
                            Spacer()
                            Button {
                                ingredients.removeAll { $0 == ingredient }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                } header: {
                    Text("Ingredients")
                }
                
                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                name = product.name
                brand = product.brand
                category = product.category
                texture = product.texture
                isAM = product.isAM
                isPM = product.isPM
                ingredients = product.ingredients
                notes = product.notes
            }
        }
    }
    
    private func addIngredient() {
        let trimmed = ingredientInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty && !ingredients.contains(trimmed) else { return }
        ingredients.append(trimmed)
        ingredientInput = ""
    }
    
    private func saveChanges() {
        product.name = name
        product.brand = brand
        product.category = category
        product.texture = texture
        product.isAM = isAM
        product.isPM = isPM
        product.ingredients = ingredients
        product.notes = notes
        dismiss()
    }
}

#Preview {
    EditProductView(product: SkinProduct(name: "Test"))
        .modelContainer(for: [SkinProduct.self, SkinJournalEntry.self], inMemory: true)
        .environment(StoreManager())
}
