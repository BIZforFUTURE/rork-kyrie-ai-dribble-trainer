//
//  VoiceCoach.swift
//  KyrieAI
//
//  On-device voice that calls out moves and gives spoken feedback during a
//  live drill, like an NBA ball-handling coach barking commands courtside.
//  Uses AVSpeechSynthesizer — fully offline, no API key, no credits.
//

import AVFoundation

@MainActor
@Observable
final class VoiceCoach {
    /// Player toggle. Persisted lightly via UserDefaults so it sticks per device.
    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "kyrie.voiceCoach.enabled")
            if !isEnabled { stop() }
        }
    }

    private let synthesizer = AVSpeechSynthesizer()
    private let voice: AVSpeechSynthesisVoice?

    init() {
        if UserDefaults.standard.object(forKey: "kyrie.voiceCoach.enabled") == nil {
            isEnabled = true
        } else {
            isEnabled = UserDefaults.standard.bool(forKey: "kyrie.voiceCoach.enabled")
        }
        // Prefer a fuller en-US voice when one is installed.
        let preferred = AVSpeechSynthesisVoice.speechVoices()
            .first { $0.language == "en-US" && $0.quality == .enhanced }
        voice = preferred ?? AVSpeechSynthesisVoice(language: "en-US")
        configureAudioSession()
    }

    /// Duck other audio (music) instead of stopping it while coaching.
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers, .mixWithOthers])
        try? session.setActive(true, options: [])
    }

    /// Punchy, immediate command (countdown, move name). Cuts off anything
    /// still speaking so callouts always land on time.
    func command(_ text: String, rate: Float = 0.56) {
        speak(text, rate: rate, pitch: 1.04, interrupt: true)
    }

    /// Short reaction after a rep. Queues behind any current speech so it
    /// doesn't stomp the move callout.
    func feedback(_ text: String, rate: Float = 0.54) {
        speak(text, rate: rate, pitch: 1.0, interrupt: false)
    }

    private func speak(_ text: String, rate: Float, pitch: Float, interrupt: Bool) {
        guard isEnabled, !text.isEmpty else { return }
        if interrupt, synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.preUtteranceDelay = 0
        utterance.postUtteranceDelay = 0
        synthesizer.speak(utterance)
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}
