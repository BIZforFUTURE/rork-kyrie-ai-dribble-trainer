//
//  PhoneVideoShowcase.swift
//  KyrieAI
//
//  A looping, muted demo video rendered inside a stylized phone frame,
//  used on the welcome screen to show the app in action.
//

import SwiftUI
import AVFoundation

/// A muted, auto-looping video view backed by AVPlayer.
struct LoopingVideoView: UIViewRepresentable {
    let resourceName: String
    let resourceExtension: String

    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        if let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension) {
            view.configure(with: url)
        }
        return view
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {}
}

/// UIView whose backing layer is an AVPlayerLayer, looping silently forever.
final class PlayerContainerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }

    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    private var looper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?

    func configure(with url: URL) {
        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer()
        player.isMuted = true
        player.actionAtItemEnd = .advance
        looper = AVPlayerLooper(player: player, templateItem: item)
        queuePlayer = player
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        player.play()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil { queuePlayer?.play() }
    }
}

/// The welcome demo video framed inside a sleek phone mockup.
struct PhoneVideoShowcase: View {
    var width: CGFloat = 188
    var resourceName: String = "welcome_demo"

    private var height: CGFloat { width * 16.0 / 9.0 }

    var body: some View {
        let screenRadius: CGFloat = width * 0.16
        let frameRadius: CGFloat = screenRadius + 7

        LoopingVideoView(resourceName: resourceName, resourceExtension: "mov")
            .frame(width: width, height: height)
            .clipShape(.rect(cornerRadius: screenRadius))
            .overlay(
                RoundedRectangle(cornerRadius: screenRadius)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
            .padding(7)
            .background(
                RoundedRectangle(cornerRadius: frameRadius)
                    .fill(Color(hex: 0x07070A))
                    .overlay(
                        RoundedRectangle(cornerRadius: frameRadius)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.22), Color.white.opacity(0.04)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.5
                            )
                    )
            )
            .overlay(alignment: .top) {
                // Dynamic Island pill
                Capsule()
                    .fill(Color.black)
                    .frame(width: width * 0.30, height: width * 0.085)
                    .padding(.top, 12)
            }
            .shadow(color: Theme.primary.opacity(0.28), radius: 34, y: 14)
            .shadow(color: .black.opacity(0.5), radius: 18, y: 10)
    }
}
