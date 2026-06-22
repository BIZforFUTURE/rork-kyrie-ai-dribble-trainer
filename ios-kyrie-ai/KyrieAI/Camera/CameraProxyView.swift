//
//  CameraProxyView.swift
//  KyrieAI
//
//  Shows the live camera feed when a real camera exists, otherwise a clean
//  placeholder (cloud simulator has no camera). Overlay content sits on top.
//

import SwiftUI
import AVFoundation

struct CameraProxyView<Overlay: View>: View {
    /// When provided, the preview uses the tracker's shared Vision session so the
    /// frames shown are the same frames being analyzed.
    var tracker: HandleTracker? = nil
    @ViewBuilder var overlay: Overlay

    private var hasCamera: Bool {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) != nil
            || AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil
    }

    var body: some View {
        ZStack {
            if hasCamera {
                if let tracker {
                    SessionCameraView(session: tracker.session)
                } else {
                    ActualCameraView()
                }
            } else {
                placeholder
            }
            overlay
        }
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0x16161E), Color(hex: 0x0C0C12)],
                startPoint: .top, endPoint: .bottom
            )
            // faint court grid
            GeometryReader { geo in
                Path { p in
                    let step: CGFloat = 44
                    var x: CGFloat = 0
                    while x < geo.size.width { p.move(to: .init(x: x, y: 0)); p.addLine(to: .init(x: x, y: geo.size.height)); x += step }
                    var y: CGFloat = 0
                    while y < geo.size.height { p.move(to: .init(x: 0, y: y)); p.addLine(to: .init(x: geo.size.width, y: y)); y += step }
                }
                .stroke(Color.white.opacity(0.04), lineWidth: 1)
            }
            VStack(spacing: 12) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(Theme.textSecondary)
                Text("Camera preview")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                Text("Install this app on your device via the Rork App to use the camera.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textTertiary)
                    .padding(.horizontal, 30)
            }
            .padding(.bottom, 60)
        }
    }
}

/// Preview backed by an externally-owned capture session (the HandleTracker's).
struct SessionCameraView: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> SessionPreviewView {
        let view = SessionPreviewView()
        view.previewLayer.videoGravity = .resizeAspectFill
        view.previewLayer.session = session
        return view
    }
    func updateUIView(_ uiView: SessionPreviewView, context: Context) {
        if uiView.previewLayer.session !== session {
            uiView.previewLayer.session = session
        }
    }
}

final class SessionPreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}

/// Real AVFoundation preview used only when a camera is present.
struct ActualCameraView: UIViewRepresentable {
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.configure()
        return view
    }
    func updateUIView(_ uiView: PreviewView, context: Context) {}
}

final class PreviewView: UIView {
    private let session = AVCaptureSession()

    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    private var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }

    func configure() {
        previewLayer.videoGravity = .resizeAspectFill
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input) else { return }
        session.addInput(input)
        previewLayer.session = session
        Task.detached { [session] in
            session.startRunning()
        }
    }
}
