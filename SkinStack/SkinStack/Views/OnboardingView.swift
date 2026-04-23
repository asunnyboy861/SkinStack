import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            onboardingPage(
                icon: "bottle.fill",
                title: "Build Your Routine",
                subtitle: "Add your skincare products and we'll organize them into the perfect AM/PM routine"
            )
            .tag(0)
            
            onboardingPage(
                icon: "exclamationmark.triangle.fill",
                title: "Detect Conflicts",
                subtitle: "Know which ingredients don't mix — avoid irritation and wasted products"
            )
            .tag(1)
            
            onboardingPage(
                icon: "timer",
                title: "Wait Time Timer",
                subtitle: "Know exactly how long to wait between products for maximum absorption"
            )
            .tag(2)
            
            onboardingPage(
                icon: "book.fill",
                title: "Track Progress",
                subtitle: "Keep a skin journal and see your improvement over time"
            )
            .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .background(Color.skinStackBackground)
        .overlay(alignment: .bottom) {
            VStack(spacing: 16) {
                if currentPage == 3 {
                    Button {
                        hasSeenOnboarding = true
                    } label: {
                        Text("Get Started")
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.skinStackPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 40)
                } else {
                    Button {
                        withAnimation {
                            currentPage += 1
                        }
                    } label: {
                        Text("Next")
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.skinStackPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 40)
                    
                    Button {
                        hasSeenOnboarding = true
                    } label: {
                        Text("Skip")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    private func onboardingPage(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(Color.skinStackPrimary)
                .padding(.bottom, 20)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
