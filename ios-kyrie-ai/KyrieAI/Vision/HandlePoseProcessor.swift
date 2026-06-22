//
//  HandlePoseProcessor.swift
//  KyrieAI
//
//  Runs Apple's Vision framework on each camera frame to actually "see" the
//  player's hands and body. From the detected joints it derives real,
//  measured handle metrics — visibility, motion energy, how low the handle
//  is, crossover side-switches, and reaction time — instead of random values.
//
//  This object is nonisolated: its delegate callback runs on a background
//  video queue. All mutable state is protected by a lock so the main actor
//  can safely read snapshots.
//

import Foundation
import AVFoundation
import Vision
import QuartzCore

/// A finished measurement for one drill rep window, derived purely from Vision.
nonisolated struct HandleRepResult {
    /// Fraction of analyzed frames where the hands were actually detected (0...1).
    let detectionRate: Double
    /// Average per-frame horizontal hand motion (normalized image units).
    let avgMotion: Double
    /// Average "lowness" of the handle (0 = high/chest, 1 = near the floor).
    let avgLowness: Double
    /// Number of times a hand crossed the body's centerline (crossover proxy).
    let crossovers: Int
    /// Lowest point the handle reached this window (0 = high, 1 = floor). A
    /// between-the-legs pass-through spikes this near 1.
    let maxLowness: Double
    /// Count of "pause then burst" motion events — the signature of a
    /// hesitation or change-of-pace move.
    let hesitationEvents: Int
    /// Time from window start to first significant hand movement, in ms (0 = none).
    let reactionMs: Int
    /// How many frames were analyzed in this window.
    let framesAnalyzed: Int
}

/// Lightweight live values polled by the UI a few times per second.
nonisolated struct HandleLiveSnapshot {
    let hands: Int
    let body: Bool
    let motion: Double
}

nonisolated final class HandlePoseProcessor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let handRequest: VNDetectHumanHandPoseRequest = {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 2
        return request
    }()
    private let bodyRequest = VNDetectHumanBodyPoseRequest()

    private let lock = NSLock()

    /// Image orientation used so detected points land in upright frame space.
    private var orientation: CGImagePropertyOrientation = .leftMirrored

    // Window accumulators
    private var frameCount = 0
    private var framesWithHands = 0
    private var framesWithBody = 0
    private var motionSum = 0.0
    private var lownessSum = 0.0
    private var crossovers = 0
    private var maxLowness = 0.0
    private var hesitationEvents = 0
    private var wasQuiet = false      // motion dropped low (a "pause")
    private var lastHandX: Double?
    private var lastSide = 0          // -1 left, +1 right, 0 unset
    private var windowStart: TimeInterval = 0
    private var firstMotionTime: TimeInterval?
    private let motionThreshold = 0.018

    // Live values
    private var liveHands = 0
    private var liveBody = false
    private var liveMotion = 0.0

    func setOrientation(_ orientation: CGImagePropertyOrientation) {
        lock.lock(); self.orientation = orientation; lock.unlock()
    }

    // MARK: - Delegate

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        lock.lock(); let orientation = self.orientation; lock.unlock()

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        do {
            try handler.perform([handRequest, bodyRequest])
        } catch {
            return
        }

        // Collect wrist points for each detected hand.
        var wrists: [CGPoint] = []
        if let observations = handRequest.results {
            for observation in observations {
                if let points = try? observation.recognizedPoints(.all),
                   let wrist = points[.wrist], wrist.confidence > 0.3 {
                    wrists.append(wrist.location)
                }
            }
        }

        // Body centerline (waist root) for crossover detection.
        var bodyX: Double?
        if let body = bodyRequest.results?.first,
           let root = try? body.recognizedPoint(.root), root.confidence > 0.2 {
            bodyX = Double(root.location.x)
        }

        ingest(wrists: wrists, bodyX: bodyX, time: CACurrentMediaTime())
    }

    private func ingest(wrists: [CGPoint], bodyX: Double?, time: TimeInterval) {
        lock.lock(); defer { lock.unlock() }

        frameCount += 1
        let hasHands = !wrists.isEmpty
        if hasHands { framesWithHands += 1 }
        if bodyX != nil { framesWithBody += 1 }

        if hasHands {
            let avgX = wrists.map { Double($0.x) }.reduce(0, +) / Double(wrists.count)
            let avgY = wrists.map { Double($0.y) }.reduce(0, +) / Double(wrists.count)
            // Vision y is normalized with origin at the bottom; a low handle has
            // a small y, so lowness = 1 - y rewards keeping the ball down.
            let frameLowness = max(0, min(1, 1 - avgY))
            lownessSum += frameLowness
            maxLowness = max(maxLowness, frameLowness)

            if let last = lastHandX {
                let motion = abs(avgX - last)
                motionSum += motion
                liveMotion = motion
                if motion > motionThreshold, firstMotionTime == nil {
                    firstMotionTime = time
                }
                // Hesitation detector: a clear quiet beat followed by an
                // explosive burst counts as one hesitation/change-of-pace.
                if motion < 0.006 {
                    wasQuiet = true
                } else if motion > 0.032 && wasQuiet {
                    hesitationEvents += 1
                    wasQuiet = false
                }
                // Crossover: the hand cluster crosses the body centerline.
                let center = bodyX ?? 0.5
                let side = avgX < center ? -1 : 1
                if abs(avgX - center) > 0.04 {
                    if side != lastSide && lastSide != 0 { crossovers += 1 }
                    lastSide = side
                }
            }
            lastHandX = avgX
        }

        liveHands = wrists.count
        liveBody = bodyX != nil
    }

    // MARK: - Window control

    func beginWindow() {
        lock.lock(); defer { lock.unlock() }
        frameCount = 0
        framesWithHands = 0
        framesWithBody = 0
        motionSum = 0
        lownessSum = 0
        crossovers = 0
        maxLowness = 0
        hesitationEvents = 0
        wasQuiet = false
        lastHandX = nil
        lastSide = 0
        firstMotionTime = nil
        windowStart = CACurrentMediaTime()
    }

    func endWindow() -> HandleRepResult {
        lock.lock(); defer { lock.unlock() }
        let frames = max(1, frameCount)
        let detectionRate = Double(framesWithHands) / Double(frames)
        let avgMotion = framesWithHands > 1 ? motionSum / Double(framesWithHands) : 0
        let avgLowness = framesWithHands > 0 ? lownessSum / Double(framesWithHands) : 0
        let reactionMs = firstMotionTime.map { Int(max(0, ($0 - windowStart)) * 1000) } ?? 0
        return HandleRepResult(
            detectionRate: detectionRate,
            avgMotion: avgMotion,
            avgLowness: avgLowness,
            crossovers: crossovers,
            maxLowness: maxLowness,
            hesitationEvents: hesitationEvents,
            reactionMs: reactionMs,
            framesAnalyzed: frameCount
        )
    }

    func snapshot() -> HandleLiveSnapshot {
        lock.lock(); defer { lock.unlock() }
        return HandleLiveSnapshot(hands: liveHands, body: liveBody, motion: liveMotion)
    }
}
