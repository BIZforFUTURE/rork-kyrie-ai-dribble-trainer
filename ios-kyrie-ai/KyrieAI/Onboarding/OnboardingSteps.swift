//
//  OnboardingSteps.swift
//  KyrieAI
//
//  Individual onboarding step screens.
//

import SwiftUI
import StoreKit

// MARK: - Welcome

struct WelcomeStep: View {
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 26) {
            Spacer(minLength: 8)
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.18))
                    .frame(width: 240)
                    .blur(radius: 40)
                    .scaleEffect(pulse ? 1.1 : 0.9)
                PhoneVideoShowcase(width: 182)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) { pulse = true }
            }

            VStack(spacing: 14) {
                Text("KYRIE AI")
                    .font(.custom("AvenirNextCondensed-Heavy", size: 52))
                    .foregroundStyle(Theme.textPrimary)
                    .tracking(4)
                Text("Your personal AI ball-handling coach. Train your handle, footwork, and creativity like an elite guard — every single day.")
                    .font(.custom("AvenirNextCondensed-Medium", size: 19))
                    .tracking(0.5)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.horizontal, 30)
            }

            HStack(spacing: 10) {
                featurePill("camera.viewfinder", "Camera AI")
                featurePill("chart.line.uptrend.xyaxis", "Tracked")
                featurePill("flame.fill", "Daily")
            }
            Spacer()
        }
        .padding(.horizontal, 22)
    }

    private func featurePill(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.caption.weight(.bold))
            Text(text).font(.caption.weight(.semibold))
        }
        .foregroundStyle(Theme.textPrimary)
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Theme.surface, in: .capsule)
        .overlay(Capsule().strokeBorder(Theme.stroke, lineWidth: 1))
    }
}

// MARK: - Drill (feature showcase)

/// Feature showcase slide framing the demo video inside a phone with the app's
/// key training capabilities listed below.
struct DrillStep: View {
    @State private var appear = false

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.18))
                    .frame(width: 280)
                    .blur(radius: 52)
                PhoneVideoShowcase(width: 230, resourceName: "drill_demo")
                    .scaleEffect(appear ? 1 : 0.92)
                    .opacity(appear ? 1 : 0)
            }

            VStack(spacing: 10) {
                Text("YOUR TRAINING")
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(Theme.energy)
                    .tracking(3)
                Text("Drill Like a Pro")
                    .font(.custom("AvenirNextCondensed-Heavy", size: 44))
                    .tracking(1)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textPrimary)
                Text("Personalized workout plans, six unique training modes, and a fresh daily challenge — all built around your game.")
                    .font(.custom("AvenirNextCondensed-Medium", size: 18))
                    .tracking(0.5)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 18)
            }

            Spacer()
        }
        .padding(.horizontal, 22)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) { appear = true }
        }
    }

    private func featureRow(_ icon: String, _ title: String, _ subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(Theme.primary)
                .frame(width: 44, height: 44)
                .background(Theme.primary.opacity(0.12), in: .rect(cornerRadius: Theme.radiusS))
                .overlay(RoundedRectangle(cornerRadius: Theme.radiusS).strokeBorder(Theme.primary.opacity(0.25), lineWidth: 1))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.radiusM))
        .overlay(RoundedRectangle(cornerRadius: Theme.radiusM).strokeBorder(Theme.stroke, lineWidth: 1))
    }
}

// MARK: - Progress (feature showcase)

/// Feature showcase slide framing the progress demo video inside a phone,
/// highlighting the in-app Progress tab and its reporting.
struct ProgressStep: View {
    @State private var appear = false

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.18))
                    .frame(width: 280)
                    .blur(radius: 52)
                PhoneVideoShowcase(width: 230, resourceName: "progress_demo")
                    .scaleEffect(appear ? 1 : 0.92)
                    .opacity(appear ? 1 : 0)
            }

            VStack(spacing: 10) {
                Text("YOUR PROGRESS")
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(Theme.energy)
                    .tracking(3)
                Text("In-Depth Reports")
                    .font(.custom("AvenirNextCondensed-Heavy", size: 42))
                    .tracking(1)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Theme.textPrimary)
                Text("Your Progress tab tracks every rep — streaks, XP, skill ratings, and session history — so you can see exactly how your handle is leveling up over time.")
                    .font(.custom("AvenirNextCondensed-Medium", size: 18))
                    .tracking(0.5)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 18)
            }

            Spacer()
        }
        .padding(.horizontal, 22)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) { appear = true }
        }
    }
}

// MARK: - Stat (persuasion reveal)

/// Three-tap persuasion sequence. Opens on the "90%" stat, the first tap
/// reveals the "a guard is only as good as his handle" truth, and the second
/// tap swaps to the 30-day promise — building urgency before the proof graph.
struct StatStep: View {
    /// 0 = the 90% stat, 1 = the handle truth, 2 = the 30-day promise.
    let phase: Int
    @State private var glow = false
    @State private var statPop = false

    var body: some View {
        VStack {
            Spacer(minLength: 0)
            Group {
                switch phase {
                case 0: statReveal
                case 1: handle
                default: promise
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .scale(scale: 0.9).combined(with: .opacity)
            ))
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 26)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) { glow = true }
            popStat()
        }
        .onChange(of: phase) { _, newValue in
            if newValue == 0 { popStat() }
        }
    }

    private func popStat() {
        statPop = false
        withAnimation(.spring(response: 0.55, dampingFraction: 0.55).delay(0.12)) { statPop = true }
    }

    // MARK: Phase 0 — the stat

    private var statReveal: some View {
        VStack(spacing: 22) {
            Text("90%")
                .font(.system(size: 128, weight: .black, design: .rounded))
                .foregroundStyle(Theme.fireGradient)
                .shadow(color: Theme.primary.opacity(0.5), radius: 28, y: 8)
                .scaleEffect(statPop ? 1 : 0.6)
                .opacity(statPop ? 1 : 0)

            VStack(spacing: 12) {
                Text("THE COLLEGE TRUTH")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Theme.energy)
                    .tracking(2)
                Text("of college players 6'3\" or under\nplay guard")
                    .font(.custom("AvenirNextCondensed-Heavy", size: 28))
                    .tracking(0.5)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: Phase 1 — the handle truth

    private var handle: some View {
        VStack(spacing: 26) {
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.16))
                    .frame(width: 150)
                    .blur(radius: 36)
                    .scaleEffect(glow ? 1.12 : 0.9)
                Image(systemName: "basketball.fill")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(Theme.fireGradient)
                    .shadow(color: Theme.primary.opacity(0.5), radius: 18)
            }

            VStack(spacing: 14) {
                Text("THE BOTTOM LINE")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Theme.energy)
                    .tracking(2)
                Text("A guard is only\nas good as his handle")
                    .font(.custom("AvenirNextCondensed-Heavy", size: 36))
                    .tracking(0.5)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Break ankles, create space, run the show — it all starts with the ball on a string.")
                    .font(.custom("AvenirNextCondensed-Medium", size: 18))
                    .tracking(0.5)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
            }
        }
    }

    // MARK: Phase 2 — the promise

    private var promise: some View {
        VStack(spacing: 26) {
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.18))
                    .frame(width: 160)
                    .blur(radius: 40)
                    .scaleEffect(glow ? 1.12 : 0.9)
                Image(systemName: "flame.fill")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(Theme.fireGradient)
                    .shadow(color: Theme.primary.opacity(0.5), radius: 18)
            }

            VStack(spacing: 12) {
                Text("THE FAST TRACK")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Theme.energy)
                    .tracking(2)
                (
                    Text("Kyrie AI can build you a real handle in ")
                        .foregroundStyle(Theme.textPrimary)
                    + Text("30 days")
                        .foregroundStyle(Theme.primary)
                    + Text(".")
                        .foregroundStyle(Theme.textPrimary)
                )
                .font(.custom("AvenirNextCondensed-Heavy", size: 34))
                .tracking(0.5)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                Text("Train daily with AI-guided drills built around your game — no trainer required.")
                    .font(.custom("AvenirNextCondensed-Medium", size: 18))
                    .tracking(0.5)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 12)
            }
        }
    }
}

// MARK: - Impact (proof bar graph)

/// Persuasion slide comparing focused minutes per game without vs. with Kyrie AI.
struct ImpactStep: View {
    @State private var animate = false

    private let withoutValue: Double = 11.5
    private let withValue: Double = 22
    private let maxValue: Double = 24

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 8)

            VStack(spacing: 10) {
                Text("THE DIFFERENCE")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Theme.energy)
                    .tracking(2)
                Text("Make every minute\non the court count")
                    .font(.custom("AvenirNextCondensed-Heavy", size: 34))
                    .tracking(0.5)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textPrimary)
                Text("Players who train with Kyrie AI nearly double their effective minutes per game.")
                    .font(.custom("AvenirNextCondensed-Medium", size: 17))
                    .tracking(0.3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.horizontal, 28)
            }

            HStack(alignment: .bottom, spacing: 28) {
                bar(
                    value: withoutValue,
                    label: "Without\nKyrie AI",
                    fill: AnyShapeStyle(Theme.surfaceElevated),
                    valueColor: Theme.textSecondary,
                    highlighted: false
                )
                bar(
                    value: withValue,
                    label: "With\nKyrie AI",
                    fill: AnyShapeStyle(Theme.fireGradient),
                    valueColor: Theme.primary,
                    highlighted: true
                )
            }
            .padding(.horizontal, 34)

            Text("Minutes played per game")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)

            Spacer()
        }
        .padding(.horizontal, 22)
        .onAppear {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.7).delay(0.15)) {
                animate = true
            }
        }
    }

    /// Total height of the plotting area (value label + bar), so both columns share a baseline.
    private let chartHeight: CGFloat = 230
    /// Tallest a bar can grow; leaves headroom above it for the floating value label.
    private let maxBarHeight: CGFloat = 186

    private func bar(value: Double, label: String, fill: AnyShapeStyle, valueColor: Color, highlighted: Bool) -> some View {
        let fraction = value / maxValue
        let barHeight = max(14, maxBarHeight * fraction)
        return VStack(spacing: 12) {
            VStack(spacing: 8) {
                Spacer(minLength: 0)
                Text(value.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(value))" : String(format: "%.1f", value))
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(valueColor)
                    .contentTransition(.numericText())
                    .opacity(animate ? 1 : 0)
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(fill)
                    .frame(height: animate ? barHeight : 0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(highlighted ? Color.clear : Theme.stroke, lineWidth: 1)
                    )
                    .shadow(color: highlighted ? Theme.primary.opacity(0.45) : .clear, radius: 16, y: 6)
            }
            .frame(maxWidth: .infinity)
            .frame(height: chartHeight, alignment: .bottom)

            Text(label)
                .font(.caption.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(highlighted ? Theme.textPrimary : Theme.textSecondary)
                .fixedSize()
        }
    }
}

// MARK: - Turnovers (proof line graph)

/// Persuasion slide showing how a player's turnovers per game drop over time
/// when training with Kyrie AI versus drifting without a plan.
struct TurnoversStep: View {
    @State private var progress: CGFloat = 0

    var body: some View {
        VStack(spacing: 26) {
            Spacer(minLength: 8)

            VStack(spacing: 10) {
                Text("THE PROOF")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Theme.energy)
                    .tracking(2)
                Text("Cut down your\nturnovers")
                    .font(Theme.display(34))
                    .tracking(0.5)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textPrimary)
                Text("Players who train with Kyrie AI protect the rock better every week — while the rest stay stuck.")
                    .font(Theme.body(17))
                    .tracking(0.3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.horizontal, 26)
            }

            chartCard
                .padding(.horizontal, 22)

            Spacer()
        }
        .padding(.horizontal, 22)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).delay(0.2)) { progress = 1 }
        }
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Turnovers per game")
                .font(Theme.display(22))
                .foregroundStyle(Theme.textPrimary)

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                ZStack {
                    // baseline grid
                    ForEach(0..<3, id: \.self) { i in
                        let y = h * (0.18 + 0.32 * CGFloat(i))
                        Path { p in
                            p.move(to: CGPoint(x: 0, y: y))
                            p.addLine(to: CGPoint(x: w, y: y))
                        }
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 5]))
                        .foregroundStyle(Theme.stroke)
                    }

                    // "Without a plan" — stays elevated / drifts up (more turnovers)
                    let withoutPts = points(for: [0.55, 0.50, 0.58, 0.52, 0.60, 0.66], in: geo.size)
                    smoothPath(withoutPts)
                        .trim(from: 0, to: progress)
                        .stroke(Theme.textTertiary, style: StrokeStyle(lineWidth: 3, lineCap: .round))

                    // "With Kyrie AI" — falls toward the floor over time (fewer turnovers)
                    let withPts = points(for: [0.55, 0.42, 0.32, 0.24, 0.16, 0.10], in: geo.size)
                    smoothPath(withPts)
                        .trim(from: 0, to: progress)
                        .fill(.clear)
                        .overlay(
                            smoothPath(withPts)
                                .trim(from: 0, to: progress)
                                .stroke(Theme.fireGradient, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .shadow(color: Theme.primary.opacity(0.5), radius: 8, y: 3)
                        )

                    // endpoint dots
                    if let endWith = withPts.last {
                        Circle()
                            .fill(Theme.primary)
                            .frame(width: 12, height: 12)
                            .position(endWith)
                            .opacity(progress > 0.95 ? 1 : 0)
                    }
                }
            }
            .frame(height: 180)

            HStack {
                legend(color: AnyShapeStyle(Theme.fireGradient), label: "With Kyrie AI", strong: true)
                Spacer()
                legend(color: AnyShapeStyle(Theme.textTertiary), label: "Without a plan", strong: false)
            }

            HStack {
                Text("Week 1").font(Theme.body(15)).foregroundStyle(Theme.textTertiary)
                Spacer()
                Text("Week 6").font(Theme.body(15)).foregroundStyle(Theme.textTertiary)
            }
        }
        .padding(20)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.radiusL))
        .overlay(RoundedRectangle(cornerRadius: Theme.radiusL).strokeBorder(Theme.stroke, lineWidth: 1))
    }

    /// Maps normalized vertical values (0 = bottom, 1 = top) to plotting points.
    private func points(for values: [CGFloat], in size: CGSize) -> [CGPoint] {
        let top: CGFloat = 0.10
        let bottom: CGFloat = 0.92
        return values.enumerated().map { index, v in
            let x = size.width * CGFloat(index) / CGFloat(values.count - 1)
            let y = size.height * (top + (1 - v) * (bottom - top))
            return CGPoint(x: x, y: y)
        }
    }

    /// Builds a smooth Catmull-Rom-ish curve through the given points.
    private func smoothPath(_ pts: [CGPoint]) -> Path {
        Path { path in
            guard let first = pts.first else { return }
            path.move(to: first)
            for i in 1..<pts.count {
                let prev = pts[i - 1]
                let curr = pts[i]
                let midX = (prev.x + curr.x) / 2
                path.addCurve(
                    to: curr,
                    control1: CGPoint(x: midX, y: prev.y),
                    control2: CGPoint(x: midX, y: curr.y)
                )
            }
        }
    }

    private func legend(color: AnyShapeStyle, label: String, strong: Bool) -> some View {
        HStack(spacing: 8) {
            Capsule()
                .fill(color)
                .frame(width: 22, height: 5)
            Text(label)
                .font(Theme.body(15))
                .foregroundStyle(strong ? Theme.textPrimary : Theme.textSecondary)
        }
    }
}

// MARK: - Rate

/// Social-proof / mission rating slide shown early in onboarding to build trust.
struct RateStep: View {
    @Environment(\.requestReview) private var requestReview
    @State private var filled = 0
    @State private var glow = false
    @State private var appear = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("SUPPORT THE MISSION")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Theme.energy)
                        .tracking(2)
                    Text("Help the Mission")
                        .font(.custom("AvenirNextCondensed-Heavy", size: 36))
                        .tracking(1)
                        .foregroundStyle(Theme.textPrimary)
                }

                missionCard
                supportCard
                starCard
            }
            .padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) { glow = true }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) { appear = true }
        }
    }

    private var missionCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "target").font(.caption.weight(.bold))
                Text("OUR MISSION").font(.caption.weight(.heavy)).tracking(2)
            }
            .foregroundStyle(Theme.primary)
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(Theme.primary.opacity(0.12), in: .capsule)
            .overlay(Capsule().strokeBorder(Theme.primary.opacity(0.3), lineWidth: 1))

            Text("50K")
                .font(.system(size: 64, weight: .black, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            Text("Hoopers leveling up")
                .font(.headline)
                .foregroundStyle(Theme.textSecondary)

            HStack {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.08))
                        Capsule()
                            .fill(Theme.fireGradient)
                            .frame(width: geo.size.width * (appear ? 0.62 : 0.0))
                    }
                }
                .frame(height: 8)
                Text("Getting there")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize()
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.radiusL))
        .overlay(RoundedRectangle(cornerRadius: Theme.radiusL).strokeBorder(Theme.primary.opacity(0.25), lineWidth: 1))
    }

    private var supportCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "heart.fill")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Theme.primary)
                    .frame(width: 44, height: 44)
                    .background(Theme.primary.opacity(0.12), in: .rect(cornerRadius: Theme.radiusS))
                Text("Support the Movement")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
            }
            Text("We believe every hooper deserves elite-level training — not just those who can afford a private trainer. A quick rating helps other players find Kyrie AI.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.radiusL))
        .overlay(RoundedRectangle(cornerRadius: Theme.radiusL).strokeBorder(Theme.stroke, lineWidth: 1))
    }

    private var starCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: index < filled ? "star.fill" : "star")
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundStyle(index < filled ? AnyShapeStyle(Theme.energyGradient) : AnyShapeStyle(Theme.textSecondary))
                        .scaleEffect(index < filled ? 1.0 : 0.9)
                        .shadow(color: index < filled ? Theme.energy.opacity(glow ? 0.7 : 0.4) : .clear, radius: 12)
                        .onTapGesture { rate(stars: index + 1) }
                }
            }
            Text("It takes 10 seconds and means the world to us.")
                .font(.subheadline)
                .italic()
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22).padding(.horizontal, 18)
        .background(Theme.energy.opacity(0.06), in: .rect(cornerRadius: Theme.radiusL))
        .overlay(RoundedRectangle(cornerRadius: Theme.radiusL).strokeBorder(Theme.energy.opacity(0.25), lineWidth: 1))
    }

    private func rate(stars: Int) {
        Haptics.success()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { filled = stars }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            requestReview()
        }
    }
}

// MARK: - Quiz Intro

/// Sets up the profile questionnaire by explaining that the upcoming questions
/// power a personalized AI training plan.
struct QuizIntroStep: View {
    @State private var appear = false
    @State private var glow = false

    var body: some View {
        ScrollView {
            VStack(spacing: 26) {
                Spacer(minLength: 8)

                ZStack {
                    Circle()
                        .fill(Theme.primary.opacity(0.16))
                        .frame(width: 150)
                        .blur(radius: 36)
                        .scaleEffect(glow ? 1.12 : 0.9)
                    Circle()
                        .strokeBorder(Theme.primary.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 132)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(Theme.primary)
                        .frame(width: 96, height: 96)
                        .background(Theme.primary.opacity(0.12), in: .rect(cornerRadius: 26, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .strokeBorder(Theme.primary.opacity(0.35), lineWidth: 1)
                        )
                }
                .scaleEffect(appear ? 1 : 0.7)
                .opacity(appear ? 1 : 0)

                VStack(spacing: 14) {
                    Text("YOUR TRAINING PROFILE")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Theme.energy)
                        .tracking(2)
                    Text("Let's Build Your\nGame Plan")
                        .font(.custom("AvenirNextCondensed-Heavy", size: 38))
                        .tracking(1)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Answer a few quick questions so Coach AI can build a training plan personalized to your game.")
                        .font(.custom("AvenirNextCondensed-Medium", size: 18))
                        .tracking(0.5)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 24)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("WHAT WE'LL COVER")
                        .font(.caption2.weight(.heavy)).tracking(1.5)
                        .foregroundStyle(Theme.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    coverRow("scope", Theme.primary, "Your Game", "Skill level, position, and dominant hand")
                    coverRow("target", Theme.energy, "Your Goals", "The skills you want to level up")
                    coverRow("calendar", Theme.primary, "Your Schedule", "The days you can put in work")
                }
                .padding(.top, 4)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 22)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) { appear = true }
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) { glow = true }
        }
    }

    private func coverRow(_ icon: String, _ tint: Color, _ title: String, _ subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 46, height: 46)
                .background(tint.opacity(0.12), in: .rect(cornerRadius: Theme.radiusS))
                .overlay(RoundedRectangle(cornerRadius: Theme.radiusS).strokeBorder(tint.opacity(0.25), lineWidth: 1))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.radiusM))
        .overlay(RoundedRectangle(cornerRadius: Theme.radiusM).strokeBorder(Theme.stroke, lineWidth: 1))
    }
}

// MARK: - Name

struct NameStep: View {
    @Bindable var draft: OnboardingDraft
    @FocusState private var focused: Bool

    var body: some View {
        StepScaffold(eyebrow: "Step 1", title: "What should\nCoach call you?", subtitle: "We'll personalize your training around your name.") {
            TextField("", text: $draft.name, prompt: Text("Your name").foregroundStyle(Theme.textTertiary))
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.textPrimary)
                .focused($focused)
                .submitLabel(.done)
                .padding(18)
                .background(Theme.surface, in: .rect(cornerRadius: Theme.radiusM))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusM)
                        .strokeBorder(focused ? Theme.primary.opacity(0.6) : Theme.stroke, lineWidth: 1.5)
                )
                .onAppear { focused = true }
        }
    }
}

// MARK: - Physicals (age + height)

struct PhysicalsStep: View {
    @Bindable var draft: OnboardingDraft

    var body: some View {
        StepScaffold(eyebrow: "Step 2", title: "Your build", subtitle: "Coach tailors footwork and handle height to your frame.") {
            VStack(spacing: 18) {
                stepperCard(title: "Age", value: "\(draft.age)", onMinus: { draft.age = max(8, draft.age - 1) }, onPlus: { draft.age = min(60, draft.age + 1) })

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Height").font(.headline).foregroundStyle(Theme.textPrimary)
                        Spacer()
                        Text(heightString).font(.headline.weight(.bold)).foregroundStyle(Theme.primary)
                    }
                    Slider(value: Binding(
                        get: { Double(draft.heightInches) },
                        set: { draft.heightInches = Int($0) }
                    ), in: 48...84, step: 1)
                    .tint(Theme.primary)
                }
                .padding(16)
                .background(Theme.surface, in: .rect(cornerRadius: Theme.radiusM))
                .overlay(RoundedRectangle(cornerRadius: Theme.radiusM).strokeBorder(Theme.stroke, lineWidth: 1))
            }
        }
    }

    private var heightString: String {
        "\(draft.heightInches / 12)'\(draft.heightInches % 12)\""
    }

    private func stepperCard(title: String, value: String, onMinus: @escaping () -> Void, onPlus: @escaping () -> Void) -> some View {
        HStack {
            Text(title).font(.headline).foregroundStyle(Theme.textPrimary)
            Spacer()
            HStack(spacing: 18) {
                circleButton("minus", action: onMinus)
                Text(value)
                    .font(.title2.weight(.heavy))
                    .foregroundStyle(Theme.primary)
                    .frame(minWidth: 50)
                    .contentTransition(.numericText())
                circleButton("plus", action: onPlus)
            }
        }
        .padding(16)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.radiusM))
        .overlay(RoundedRectangle(cornerRadius: Theme.radiusM).strokeBorder(Theme.stroke, lineWidth: 1))
    }

    private func circleButton(_ icon: String, action: @escaping () -> Void) -> some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation(.snappy) { action() }
        } label: {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(Theme.textPrimary)
                .frame(width: 40, height: 40)
                .background(Theme.surfaceElevated, in: .circle)
                .overlay(Circle().strokeBorder(Theme.stroke, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Skill

struct SkillStep: View {
    @Bindable var draft: OnboardingDraft

    var body: some View {
        StepScaffold(eyebrow: "Step 3", title: "Skill level", subtitle: "Be honest — Coach calibrates your plan from here.") {
            VStack(spacing: 12) {
                ForEach(SkillLevel.allCases) { level in
                    SelectRow(
                        title: level.rawValue,
                        subtitle: level.subtitle,
                        isSelected: draft.skillLevel == level
                    ) { draft.skillLevel = level }
                }
            }
        }
    }
}

// MARK: - Position

struct PositionStep: View {
    @Bindable var draft: OnboardingDraft

    var body: some View {
        StepScaffold(eyebrow: "Step 4", title: "Your position", subtitle: "Different spots demand different handles.") {
            VStack(spacing: 12) {
                ForEach(Position.allCases) { pos in
                    SelectRow(
                        title: pos.rawValue,
                        subtitle: pos.short,
                        isSelected: draft.position == pos
                    ) { draft.position = pos }
                }
            }
        }
    }
}

// MARK: - Hand

struct HandStep: View {
    @Bindable var draft: OnboardingDraft

    var body: some View {
        StepScaffold(eyebrow: "Step 5", title: "Dominant hand", subtitle: "We'll push your weak hand to catch up fast.") {
            HStack(spacing: 14) {
                ForEach(Hand.allCases) { hand in
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        draft.dominantHand = hand
                    } label: {
                        VStack(spacing: 14) {
                            Image(systemName: hand == .left ? "hand.point.left.fill" : "hand.point.right.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(draft.dominantHand == hand ? Theme.primary : Theme.textSecondary)
                            Text(hand.rawValue).font(.headline).foregroundStyle(Theme.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                        .background(
                            draft.dominantHand == hand ? Theme.primary.opacity(0.12) : Theme.surface,
                            in: .rect(cornerRadius: Theme.radiusL)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.radiusL)
                                .strokeBorder(draft.dominantHand == hand ? Theme.primary.opacity(0.6) : Theme.stroke, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Goals

struct GoalsStep: View {
    @Bindable var draft: OnboardingDraft

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        StepScaffold(eyebrow: "Step 6", title: "Your goals", subtitle: "Pick everything you want to level up. Choose as many as you like.") {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(TrainingGoal.allCases) { goal in
                    let selected = draft.goals.contains(goal)
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        if selected { draft.goals.remove(goal) } else { draft.goals.insert(goal) }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: goal.icon)
                                .font(.headline.weight(.bold))
                                .foregroundStyle(selected ? Theme.energy : Theme.textSecondary)
                            Text(goal.rawValue)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
                        .background(
                            selected ? Theme.energy.opacity(0.12) : Theme.surface,
                            in: .rect(cornerRadius: Theme.radiusM)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.radiusM)
                                .strokeBorder(selected ? Theme.energy.opacity(0.6) : Theme.stroke, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Availability

struct AvailabilityStep: View {
    @Bindable var draft: OnboardingDraft

    private let columns = [GridItem(.adaptive(minimum: 96), spacing: 12)]

    var body: some View {
        StepScaffold(eyebrow: "Step 7", title: "Training\ndays", subtitle: "Pick the days you can put in work. Coach builds your weekly plan around them.") {
            VStack(alignment: .leading, spacing: 16) {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Weekday.allCases) { day in
                        DayToggle(day: day, isSelected: draft.trainingDays.contains(day)) {
                            Haptics.select()
                            if draft.trainingDays.contains(day) {
                                draft.trainingDays.remove(day)
                            } else {
                                draft.trainingDays.insert(day)
                            }
                        }
                    }
                }

                if !draft.trainingDays.isEmpty {
                    Text("\(draft.trainingDays.count) days / week · \(Availability.from(dayCount: draft.trainingDays.count).subtitle)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.energy)
                        .transition(.opacity)
                }
            }
        }
    }
}

/// Compact rounded toggle representing a single weekday.
struct DayToggle: View {
    let day: Weekday
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(day.short)
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(isSelected ? Color(hex: 0x0B0B0F) : Theme.textPrimary)
                Text(day.rawValue.prefix(3).uppercased())
                    .font(.caption2.weight(.bold)).tracking(1)
                    .foregroundStyle(isSelected ? Color(hex: 0x0B0B0F).opacity(0.7) : Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                isSelected ? AnyShapeStyle(Theme.energyGradient) : AnyShapeStyle(Theme.surface),
                in: .rect(cornerRadius: Theme.radiusM)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusM)
                    .strokeBorder(isSelected ? .clear : Theme.stroke, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Specific Requests

struct RequestsStep: View {
    @Bindable var draft: OnboardingDraft
    @FocusState private var focused: Bool

    private let suggestions = [
        "Kyrie-style combos",
        "Tighter, lower handle",
        "More weak-hand reps",
        "Game-speed moves",
        "Less footwork drills",
        "Build finishing creativity"
    ]

    var body: some View {
        StepScaffold(eyebrow: "Step 8", title: "Anything you\nwant from Coach?", subtitle: "Tell Coach exactly what to emphasize or avoid. This shapes your plan. Optional — skip if you're not sure.") {
            VStack(alignment: .leading, spacing: 16) {
                ZStack(alignment: .topLeading) {
                    if draft.specificRequests.isEmpty {
                        Text("e.g. Focus on between-the-legs combos and explosive first steps for game situations…")
                            .font(.body)
                            .foregroundStyle(Theme.textTertiary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 10)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $draft.specificRequests)
                        .font(.body)
                        .foregroundStyle(Theme.textPrimary)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 140)
                        .focused($focused)
                }
                .padding(12)
                .background(Theme.surface, in: .rect(cornerRadius: Theme.radiusM))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusM)
                        .strokeBorder(focused ? Theme.primary.opacity(0.6) : Theme.stroke, lineWidth: 1.5)
                )

                Text("QUICK ADD")
                    .font(.caption2.weight(.heavy)).tracking(1.5)
                    .foregroundStyle(Theme.textTertiary)

                SuggestionChips(items: suggestions) { suggestion in
                    appendSuggestion(suggestion)
                }
            }
        }
    }

    private func appendSuggestion(_ text: String) {
        Haptics.select()
        let trimmed = draft.specificRequests.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            draft.specificRequests = text
        } else if !trimmed.localizedCaseInsensitiveContains(text) {
            draft.specificRequests = trimmed + ", " + text
        }
    }
}

/// Simple wrapping chip layout for quick-add suggestions.
struct SuggestionChips: View {
    let items: [String]
    let onTap: (String) -> Void

    private let columns = [GridItem(.adaptive(minimum: 130), spacing: 10)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
            ForEach(items, id: \.self) { item in
                Button { onTap(item) } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus").font(.caption2.weight(.bold))
                        Text(item).font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(Theme.textPrimary)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Theme.surface, in: .capsule)
                    .overlay(Capsule().strokeBorder(Theme.stroke, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Ready

struct ReadyStep: View {
    let draft: OnboardingDraft
    @State private var appear = false

    var body: some View {
        VStack(spacing: 26) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 84))
                .foregroundStyle(Theme.energyGradient)
                .scaleEffect(appear ? 1 : 0.5)
                .shadow(color: Theme.energy.opacity(0.5), radius: 20)

            VStack(spacing: 12) {
                Text("You're set, \(draft.name.split(separator: " ").first.map(String.init) ?? "Hooper")!")
                    .font(.custom("AvenirNextCondensed-Heavy", size: 32))
                    .tracking(0.5)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textPrimary)
                Text("Next, Coach runs a quick AI skill assessment to measure your handle and build your custom development plan.")
                    .font(.custom("AvenirNextCondensed-Medium", size: 17))
                    .tracking(0.3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.horizontal, 24)
            }

            VStack(spacing: 10) {
                summaryRow("Level", draft.skillLevel?.rawValue ?? "—")
                summaryRow("Position", draft.position?.rawValue ?? "—")
                summaryRow("Focus", "\(draft.goals.count) goals")
                summaryRow("Schedule", scheduleSummary)
                if !draft.specificRequests.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    summaryRow("Request", "Noted ✓")
                }
            }
            .glassCard()
            .padding(.horizontal, 22)
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) { appear = true }
        }
    }

    private var scheduleSummary: String {
        let count = draft.trainingDays.count
        return count == 0 ? "—" : "\(count) days / week"
    }

    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value).font(.subheadline.weight(.bold)).foregroundStyle(Theme.textPrimary)
        }
    }
}
