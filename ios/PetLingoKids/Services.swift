import AVFoundation
import Speech
import SwiftUI

@MainActor
final class SpeechService: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    @Published var recognizedText = ""
    @Published var score = 0

    func speak(_ text: String, chinese: Bool = false) {
        AudioServicesPlaySystemSound(1104)
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: chinese ? "zh-TW" : "en-US")
        utterance.rate = chinese ? 0.46 : 0.42
        synthesizer.speak(utterance)
    }

    func success() {
        AudioServicesPlaySystemSound(1025)
    }

    func fail() {
        AudioServicesPlaySystemSound(1053)
    }
}

@MainActor
final class ProgressStore: ObservableObject {
    @AppStorage("stars") var stars = 0
    @AppStorage("unlockedLevel") var unlockedLevel = 1
    @AppStorage("todayCount") var todayCount = 0
    @AppStorage("correct") var correct = 0
    @AppStorage("attempts") var attempts = 0
    @AppStorage("startedAt") private var startedAt = Date().timeIntervalSince1970

    var accuracy: Int { attempts == 0 ? 0 : Int(Double(correct) / Double(attempts) * 100) }
    var minutes: Int { max(1, Int((Date().timeIntervalSince1970 - startedAt) / 60)) }

    func learnedWord() {
        stars += 1
        todayCount = min(todayCount + 1, 999)
    }

    func answer(correct isCorrect: Bool) {
        attempts += 1
        if isCorrect {
            correct += 1
            stars += 1
        }
    }
}
