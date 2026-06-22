//
//  PlanBuildingView.swift
//  KyrieAI
//
//  Engaging "Coach is building your plan" waiting screen shown after the
//  assessment while Kyrie AI assembles the personalized development plan.
//

import SwiftUI

struct PlanBuildingView: View {
    let profile: PlayerProfile
    let onComplete: () -> Void

    @State private var spin = false
    @State private var pulse = false
    @State private var ringProgress: Double = 0
    @State private var stepIndex: Int = 0
    @State private var orbitAngle: Double = 0

    /// Steps tick through to make the wait feel like real work is happening.
    private var steps: [String] {
        var s = [
            "Analyzing your handle reps",
            "Mapping strengths & weak spots",
            "Matching elite move library",
            "Tuning to your \(profile.availability.rawValue.lowercased()) schedule"
        ]
        if !profile.specificRequests.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            s.append("Building in your personal request")
        }
        s.append("Finalizing your development plan")
        return s
    }

    private var totalDuration: Double { 4.4 }

    var body: some View {
        ZStack {
            ArenaBackground()

            VStack(spacing: 40) {
                Spacer()

                orb

                VStack(spacing: 10) {
                    Text("COACH IS BUILDING\nYOUR PLAN")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.textPrimary)
                        .tracking(1)
                    Text("Crafting a plan for \(profile.firstName)")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }

                stepList

                Spacer()
            }
            .padding(.horizontal, 28)
        }
        .preferredColorScheme(.dark)
        .onAppear { run() }
    }

    // MARK: Orb

    private var orb: some View {
        ZStack {
            Circle()
                .fill(Theme.primary.opacity(0.18))
                .frame(width: 240)
                .blur(radius: 40)
                .scaleEffect(pulse ? 1.12 : 0.92)

            // progress ring
            Circle()
                .stroke(Color.white.opacity(0.07), lineWidth: 10)
                .frame(width: 180)
            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(Theme.fireGradient, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 180)
                .rotationEffect(.degrees(-90))

            // orbiting energy dot
            Circle()
                .fill(Theme.energy)
                .frame(width: 14)
                .shadow(color: Theme.energy, radius: 8)
                .offset(y: -90)
                .rotationEffect(.degrees(orbitAngle))

            Image(systemName: "basketball.fill")
                .font(.system(size: 76))
                .foregroundStyle(Theme.fireGradient)
                .rotationEffect(.degrees(spin ? 360 : 0))
                .shadow(color: Theme.primary.opacity(0.6), radius: 20)
        }
        .frame(height: 240)
    }

    // MARK: Step list

    private var stepList: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                HStack(spacing: 14) {
                    ZStack {
                        if idx < stepIndex {
                            Circle().fill(Theme.energy)
                                .frame(width: 24, height: 24)
                            Image(systemName: "checkmark")
                                .font(.caption2.weight(.black))
                                .foregroundStyle(Color(hex: 0x0B0B0F))
                        } else if idx == stepIndex {
                            Circle().strokeBorder(Theme.primary, lineWidth: 2)
                                .frame(width: 24, height: 24)
                            ProgressView()
                                .controlSize(.mini)
                                .tint(Theme.primary)
                        } else {
                            Circle().strokeBorder(Theme.textTertiary, lineWidth: 2)
                                .frame(width: 24, height: 24)
                        }
                    }
                    Text(step)
                        .font(.subheadline.weight(idx == stepIndex ? .bold : .semibold))
                        .foregroundStyle(idx <= stepIndex ? Theme.textPrimary : Theme.textTertiary)
                    Spacer(minLength: 0)
                }
                .opacity(idx <= stepIndex ? 1 : 0.5)
            }
        }
        .glassCard()
    }

    // MARK: Animation driver

    private func run() {
        withAnimation(.linear(duration: 2.6).repeatForever(autoreverses: false)) { spin = true }
        withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) { pulse = true }
        withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) { orbitAngle = 360 }
        withAnimation(.easeInOut(duration: totalDuration)) { ringProgress = 1 }

        let count = steps.count
        let interval = totalDuration / Double(count)
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { stepIndex = i }
                Haptics.light()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            stepIndex = count
            Haptics.success()
            onComplete()
        }
    }
}
