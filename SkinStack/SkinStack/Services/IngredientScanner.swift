import Foundation
import Vision
import UIKit

@Observable
final class IngredientScanner {
    var scannedIngredients: [String] = []
    var isScanning: Bool = false
    var errorMessage: String?
    
    func scanImage(_ uiImage: UIImage) async {
        isScanning = true
        errorMessage = nil
        scannedIngredients = []
        
        guard let cgImage = uiImage.cgImage else {
            errorMessage = "Could not process image"
            isScanning = false
            return
        }
        
        let recognizedText = await recognizeText(in: cgImage)
        let ingredients = parseIngredients(from: recognizedText)
        scannedIngredients = ingredients
        isScanning = false
    }
    
    private func recognizeText(in cgImage: CGImage) async -> String {
        await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, _ in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }
                let text = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: " ")
                continuation.resume(returning: text)
            }
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US"]
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: "")
            }
        }
    }
    
    private func parseIngredients(from text: String) -> [String] {
        let cleaned = text
            .replacingOccurrences(of: "Ingredients:", with: "")
            .replacingOccurrences(of: "INGREDIENTS:", with: "")
            .replacingOccurrences(of: "ingredients:", with: "")
        
        let components = cleaned
            .components(separatedBy: CharacterSet(charactersIn: ",;•·"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count > 2 }
        
        return components
    }
}
