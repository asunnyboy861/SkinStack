import SwiftUI
import SwiftData
import PhotosUI

struct AddProductView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreManager.self) private var storeManager
    @Environment(ConflictDetectionEngine.self) private var conflictEngine
    @Query private var existingProducts: [SkinProduct]
    
    @State private var name = ""
    @State private var brand = ""
    @State private var category: ProductCategory = .serum
    @State private var texture: ProductTexture = .lotion
    @State private var isAM = true
    @State private var isPM = true
    @State private var ingredients: [String] = []
    @State private var ingredientInput = ""
    @State private var notes = ""
    @State private var showingScanner = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var scanImage: UIImage?
    @State private var conflictResults: [ConflictResult] = []
    
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
                            .onSubmit {
                                addIngredient()
                            }
                        Button("Add", action: addIngredient)
                            .disabled(ingredientInput.isEmpty)
                    }
                    
                    if storeManager.isPro {
                        Button {
                            showingScanner = true
                        } label: {
                            Label("Scan Ingredients (Camera)", systemImage: "camera.fill")
                        }
                    } else {
                        Button {
                            
                        } label: {
                            Label("Scan Ingredients (Pro)", systemImage: "lock.fill")
                        }
                        .foregroundStyle(.secondary)
                    }
                    
                    ForEach(ingredients, id: \.self) { ingredient in
                        HStack {
                            Text(ingredient)
                            Spacer()
                            Button {
                                ingredients.removeAll { $0 == ingredient }
                                updateConflicts()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                } header: {
                    Text("Ingredients")
                } footer: {
                    if !conflictResults.isEmpty {
                        Text("\(conflictResults.filter { $0.level == .avoid }.count) avoid, \(conflictResults.filter { $0.level == .caution }.count) caution conflicts detected")
                            .foregroundStyle(Color.skinStackConflict)
                    }
                }
                
                if !conflictResults.isEmpty {
                    Section("Conflicts") {
                        ForEach(conflictResults) { conflict in
                            ConflictBadge(conflict: conflict)
                        }
                    }
                }
                
                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProduct()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingScanner) {
                IngredientScannerView(ingredients: $ingredients)
            }
            .onChange(of: ingredients) {
                updateConflicts()
            }
        }
    }
    
    private func addIngredient() {
        let trimmed = ingredientInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty && !ingredients.contains(trimmed) else { return }
        ingredients.append(trimmed)
        ingredientInput = ""
    }
    
    private func updateConflicts() {
        let tempProduct = SkinProduct(
            name: name,
            brand: brand,
            category: category,
            texture: texture,
            ingredients: ingredients,
            isAM: isAM,
            isPM: isPM
        )
        conflictResults = conflictEngine.detectConflicts(for: tempProduct, against: existingProducts, isPro: storeManager.isPro)
    }
    
    private func saveProduct() {
        let product = SkinProduct(
            name: name,
            brand: brand,
            category: category,
            texture: texture,
            ingredients: ingredients,
            isAM: isAM,
            isPM: isPM,
            notes: notes
        )
        modelContext.insert(product)
        dismiss()
    }
}

struct IngredientScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var ingredients: [String]
    @State private var scanner = IngredientScanner()
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                if scanner.isScanning {
                    ProgressView("Scanning ingredients...")
                } else if !scanner.scannedIngredients.isEmpty {
                    Text("Found \(scanner.scannedIngredients.count) ingredients")
                        .font(.headline)
                        .foregroundStyle(Color.skinStackSafe)
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(scanner.scannedIngredients, id: \.self) { ingredient in
                                HStack {
                                    Image(systemName: ingredients.contains(ingredient) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(ingredients.contains(ingredient) ? Color.skinStackSafe : .secondary)
                                    Text(ingredient)
                                    Spacer()
                                    Button {
                                        if ingredients.contains(ingredient) {
                                            ingredients.removeAll { $0 == ingredient }
                                        } else {
                                            ingredients.append(ingredient)
                                        }
                                    } label: {
                                        Text(ingredients.contains(ingredient) ? "Remove" : "Add")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    ContentUnavailableView(
                        "Scan Ingredients",
                        systemImage: "camera.fill",
                        description: Text("Take a photo of the ingredient list on your product")
                    )
                }
                
                Spacer()
            }
            .padding()
            .background(Color.skinStackBackground)
            .navigationTitle("Ingredient Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCamera = true
                    } label: {
                        Image(systemName: "camera")
                    }
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraView { image in
                    capturedImage = image
                    Task {
                        await scanner.scanImage(image)
                    }
                }
            }
        }
    }
}

#Preview {
    AddProductView()
        .modelContainer(for: [SkinProduct.self, SkinJournalEntry.self], inMemory: true)
        .environment(StoreManager())
        .environment(ConflictDetectionEngine())
}
