import SwiftUI
import SwiftData
import UserNotifications

struct WaitTimeTimerView: View {
    let steps: [RoutineStep]
    @Environment(\.dismiss) private var dismiss
    @State private var currentStepIndex = 0
    @State private var timeRemaining: Int = 0
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    
    private var currentStep: RoutineStep? {
        guard currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }
    
    private var totalTime: Int {
        guard let step = currentStep, let wait = step.waitTimeSeconds else { return 0 }
        return wait
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                if let step = currentStep {
                    Text("Step \(step.stepNumber) of \(steps.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(step.product.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if step.waitTimeSeconds != nil {
                        timerDisplay
                        
                        timerControls
                        
                        progressView
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(Color.skinStackSafe)
                            Text("Apply \(step.product.name)")
                                .font(.headline)
                            Text("No wait time needed for this step")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 40)
                        
                        nextButton
                    }
                } else {
                    completionView
                }
            }
            .padding()
            .background(Color.skinStackBackground)
            .navigationTitle("Routine Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        stopTimer()
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let step = currentStep, let wait = step.waitTimeSeconds {
                    timeRemaining = wait
                }
            }
        }
    }
    
    private var timerDisplay: some View {
        ZStack {
            Circle()
                .stroke(Color.skinStackPrimary.opacity(0.2), lineWidth: 8)
                .frame(width: 180, height: 180)
            
            Circle()
                .trim(from: 0, to: totalTime > 0 ? CGFloat(timeRemaining) / CGFloat(totalTime) : 0)
                .stroke(Color.skinStackPrimary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 4) {
                Text(formatTime(timeRemaining))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text("remaining")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var timerControls: some View {
        HStack(spacing: 24) {
            Button {
                resetTimer()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(width: 56, height: 56)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Button {
                if isTimerRunning {
                    pauseTimer()
                } else {
                    startTimer()
                }
            } label: {
                Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 72, height: 72)
                    .background(Color.skinStackPrimary)
                    .clipShape(Circle())
            }
            
            Button {
                skipStep()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(width: 56, height: 56)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Circle())
            }
        }
    }
    
    private var progressView: some View {
        HStack(spacing: 6) {
            ForEach(0..<steps.count, id: \.self) { index in
                Circle()
                    .fill(index <= currentStepIndex ? Color.skinStackPrimary : Color.skinStackPrimary.opacity(0.2))
                    .frame(width: 8, height: 8)
            }
        }
    }
    
    private var nextButton: some View {
        Button {
            moveToNextStep()
        } label: {
            Text(currentStepIndex < steps.count - 1 ? "Next Step" : "Finish")
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.skinStackPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(Color.skinStackPrimary)
            Text("Routine Complete!")
                .font(.title2)
                .fontWeight(.bold)
            Text("Great job following your skincare routine")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button {
                dismiss()
            } label: {
                Text("Done")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.skinStackPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 20)
        }
    }
    
    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
                scheduleNotification()
            }
        }
    }
    
    private func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        stopTimer()
        if let step = currentStep, let wait = step.waitTimeSeconds {
            timeRemaining = wait
        }
    }
    
    private func skipStep() {
        stopTimer()
        moveToNextStep()
    }
    
    private func moveToNextStep() {
        currentStepIndex += 1
        if let step = currentStep, let wait = step.waitTimeSeconds {
            timeRemaining = wait
        } else {
            timeRemaining = 0
        }
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "SkinStack Timer"
        content.body = "Time's up! Ready for the next step."
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

#Preview {
    WaitTimeTimerView(steps: [
        RoutineStep(product: SkinProduct(name: "Cleanser", category: .cleanser, texture: .gel), stepNumber: 1, waitTimeSeconds: 60, conflictWarnings: []),
        RoutineStep(product: SkinProduct(name: "Serum", category: .serum, texture: .water), stepNumber: 2, waitTimeSeconds: 120, conflictWarnings: [])
    ])
}
