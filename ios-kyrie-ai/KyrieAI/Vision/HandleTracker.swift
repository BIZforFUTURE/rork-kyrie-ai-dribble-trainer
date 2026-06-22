//
//  HandleTracker.swift
//  KyrieAI
//
//  Owns the live camera session and the Vision pipeline. The session feeds
//  both the on-screen preview and the HandlePoseProcessor, so the same frames
//  the player sees are the frames Kyrie AI analyzes. Exposes live, observable
//  metrics for the UI plus rep-window grading for scoring.
//

import SwiftUI
import AVFoundation
import Vision

@Observable
@MainActor
final class HandleTracker {
    /// Shared capture session, also handed to the preview layer.
    let session = AVCaptureSession()

    private let processor = HandlePoseProcessor()
    private let videoQueue = DispatchQueue(label: "ai.kyrie.video", qos: .userInitiated)
    private var configured = false
    private var pollTimer: Timer?

    // Live, observable metrics for the UI.
    var handsDetected = 0
    var bodyInFrame = false
    var motionLevel = 0.0   // 0...1, smoothed
    /// True when a real camera + Vision pipeline is running (false in the simulator).
    var isAvailable = false

    var hasCamera: Bool {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) != nil
            || AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil
    }

    /// True once the player's hands are clearly in frame and being tracked.
    var isLocked: Bool { isAvailable && handsDetected > 0 && bodyInFrame }

    func startSession() {
        guard hasCamera else { isAvailable = false; return }
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard granted else { return }
            Task { @MainActor in self?.beginRunning() }
        }
    }

    private func beginRunning() {
        configureIfNeeded()
        guard configured else { return }
        isAvailable = true
        let captureSession = session
        videoQueue.async {
            if !captureSession.isRunning { captureSession.startRunning() }
        }
        startPolling()
    }

    func stopSession() {
        pollTimer?.invalidate(); pollTimer = nil
        let captureSession = session
        videoQueue.async {
            if captureSession.isRunning { captureSession.stopRunning() }
        }
    }

    private func configureIfNeeded() {
        guard !configured else { return }
        let position: AVCaptureDevice.Position =
            AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) != nil ? .front : .back
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        session.beginConfiguration()
        session.sessionPreset = .high
        if session.canAddInput(input) { session.addInput(input) }

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(processor, queue: videoQueue)
        if session.canAddOutput(output) { session.addOutput(output) }
        session.commitConfiguration()

        // Front camera in portrait needs mirrored-left so detected points are upright.
        processor.setOrientation(position == .front ? .leftMirrored : .right)
        configured = true
    }

    private func startPolling() {
        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                let snap = self.processor.snapshot()
                self.handsDetected = snap.hands
                self.bodyInFrame = snap.body
                // Smooth the motion bar and scale to a readable 0...1 range.
                let scaled = min(1, snap.motion / 0.05)
                self.motionLevel = self.motionLevel * 0.6 + scaled * 0.4
            }
        }
    }

    // MARK: - Rep grading

    func beginWindow() { processor.beginWindow() }
    func endWindow() -> HandleRepResult { processor.endWindow() }
}
