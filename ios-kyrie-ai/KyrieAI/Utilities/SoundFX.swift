//
//  SoundFX.swift
//  KyrieAI
//
//  Lightweight in-app sound effects. Players are cached and pre-loaded so
//  cues fire without latency, and playback shares the ambient audio session
//  so it never interrupts the voice coach or background audio.
//

import AVFoundation

/// App-wide sound effect helper.
///
/// Use the semantic methods (`repSuccess`) rather than instantiating
/// `AVAudioPlayer` directly so cues stay consistent and pre-warmed.
@MainActor
enum SoundFX {
    private static var players: [String: AVAudioPlayer] = [:]
    private static var sessionConfigured = false

    /// Positive reward chime played after each completed exercise/rep.
    static func repSuccess() {
        play("rep_success", volume: 0.9)
    }

    /// Pre-load the bundled effects so the first cue is instant.
    static func prepareAll() {
        configureSession()
        _ = player(for: "rep_success")
    }

    // MARK: - Internals

    private static func configureSession() {
        guard !sessionConfigured else { return }
        sessionConfigured = true
        // Ambient + mixWithOthers so SFX layer over the voice coach and any
        // background music without ducking or stopping them.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private static func play(_ name: String, volume: Float) {
        configureSession()
        guard let p = player(for: name) else { return }
        p.volume = volume
        p.currentTime = 0
        p.play()
    }

    private static func player(for name: String) -> AVAudioPlayer? {
        if let existing = players[name] { return existing }
        let exts = ["mp3", "wav", "m4a", "caf"]
        guard let url = exts.lazy
            .compactMap({ Bundle.main.url(forResource: name, withExtension: $0) })
            .first else { return nil }
        guard let p = try? AVAudioPlayer(contentsOf: url) else { return nil }
        p.prepareToPlay()
        players[name] = p
        return p
    }
}
