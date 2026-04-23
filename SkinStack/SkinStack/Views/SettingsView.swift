import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(StoreManager.self) private var storeManager
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showingPaywall = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationStack {
            List {
                proSection
                dataSection
                aboutSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
    
    private var proSection: some View {
        Section {
            if storeManager.isPro {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(Color.skinStackCaution)
                    Text("SkinStack Pro")
                        .fontWeight(.medium)
                    Spacer()
                    Text("Active")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.skinStackSafe.opacity(0.15))
                        .foregroundStyle(Color.skinStackSafe)
                        .clipShape(Capsule())
                }
            } else {
                Button {
                    showingPaywall = true
                } label: {
                    HStack {
                        Image(systemName: "crown")
                            .foregroundStyle(Color.skinStackCaution)
                        Text("Upgrade to Pro")
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        Spacer()
                        Text("$4.99")
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }
    
    private var dataSection: some View {
        Section("Data") {
            Button {
                hasSeenOnboarding = false
            } label: {
                Label("Show Onboarding", systemImage: "hand.wave.fill")
            }
        }
    }
    
    private var aboutSection: some View {
        Section("About") {
            Link(destination: URL(string: "mailto:support@zzoutuo.com?subject=SkinStack%20Feedback")!) {
                Label("Contact Support", systemImage: "envelope.fill")
            }
            Link(destination: URL(string: "https://zzoutuo.com/skinstack/privacy")!) {
                Label("Privacy Policy", systemImage: "hand.raised.fill")
            }
            Link(destination: URL(string: "https://zzoutuo.com/skinstack/terms")!) {
                Label("Terms of Use", systemImage: "doc.text.fill")
            }
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(StoreManager())
}
