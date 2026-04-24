import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(StoreManager.self) private var storeManager
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featuresSection
                    purchaseSection
                    restoreSection
                    legalSection
                }
                .padding()
            }
            .background(Color.skinStackBackground)
            .navigationTitle("SkinStack Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.skinStackCaution)
            Text("Unlock Your Best Skin")
                .font(.title2)
                .fontWeight(.bold)
            Text("One-time purchase. No subscription.")
                .font(.subheadline)
                .foregroundStyle(Color.skinStackSafe)
                .fontWeight(.medium)
        }
        .padding(.top, 20)
    }
    
    private var featuresSection: some View {
        VStack(spacing: 16) {
            PaywallFeatureRow(icon: "infinity", title: "Unlimited Products", description: "Add as many products as you need")
            PaywallFeatureRow(icon: "brain.head.profile", title: "Smart Routine Builder", description: "AI-powered AM/PM routine optimization")
            PaywallFeatureRow(icon: "camera.fill", title: "Ingredient Scanner", description: "Scan labels with your camera")
            PaywallFeatureRow(icon: "timer", title: "Wait-Time Timer", description: "Know exactly when to apply next product")
            PaywallFeatureRow(icon: "book.fill", title: "Skin Journal", description: "Track your skin condition over time")
            PaywallFeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Trend Charts", description: "See your skin improvement trends")
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var purchaseSection: some View {
        Button {
            Task {
                isPurchasing = true
                await storeManager.purchasePro()
                isPurchasing = false
                if storeManager.isPro {
                    dismiss()
                }
            }
        } label: {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Unlock Pro - $4.99")
                        .fontWeight(.bold)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.skinStackPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isPurchasing)
    }
    
    private var restoreSection: some View {
        Button {
            Task {
                await storeManager.restorePurchases()
                if storeManager.isPro {
                    dismiss()
                }
            }
        } label: {
            Text("Restore Purchases")
                .font(.subheadline)
                .foregroundStyle(Color.skinStackSecondary)
        }
    }
    
    private var legalSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/SkinStack-privacy/")!)
                Link("Terms of Use", destination: URL(string: "https://asunnyboy861.github.io/SkinStack-terms/")!)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            Text("One-time purchase. No auto-renewal.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.bottom, 20)
    }
}

struct PaywallFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.skinStackPrimary)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.skinStackSafe)
        }
    }
}

#Preview {
    PaywallView()
        .environment(StoreManager())
}
