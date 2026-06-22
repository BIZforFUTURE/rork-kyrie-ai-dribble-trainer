//
//  SessionResultView.swift
//  KyrieAI
//
//  Post-session breakdown with XP, accuracy, reaction, and coach feedback.
//

import SwiftUI

struct SessionResultView: View {
    let profile: PlayerProfile
    let mode: TrainingMode
    let vm: TrainingSessionViewModel
    let onDone: () -> Void

    @State private var appear = false

    private var coachLine: String {
        switch vm.resultAccuracy {
        case 90...: return "Filthy handles. That was elite-level execution — keep this in your bag."
        case 78..<90: return "Smooth and controlled. You're locking these moves in. Push the pace next time."
        case 65..<78: return "Solid work. Tighten your control on the combos and you'll level up fast."
        default: return "Good reps. Slow it down, stay low, and focus on clean contact with the ball."
        }
    }

    var body: some View {
        ZStack {
            ArenaBackground()
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(mode.tint)
                            .scaleEffect(appear ? 1 : 0.4)
                            .shadow(color: mode.tint.opacity(0.5), radius: 18)
                        Text("Session Complete")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                        Text(mode.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.top, 40)

                    // XP banner
                    HStack {
                        Image(systemName: "bolt.fill").foregroundStyle(Theme.energy)
                        Text("+\(vm.resultXP) XP earned")
                            .font(.headline.weight(.heavy))
                            .foregroundStyle(Theme.textPrimary)
                    }
                    .padding(.horizontal, 20).padding(.vertical, 14)
                    .background(Theme.energy.opacity(0.14), in: .capsule)
                    .overlay(Capsule().strokeBorder(Theme.energy.opacity(0.5), lineWidth: 1))

                    HStack(spacing: 12) {
                        StatChip(value: "\(vm.resultAccuracy)%", label: "Execution", tint: mode.tint, icon: "scope")
                        StatChip(value: "\(vm.resultReactionMs)ms", label: "Avg reaction", tint: Theme.info, icon: "timer")
                        StatChip(value: "\(vm.samples.count)", label: "Moves", tint: Theme.energy, icon: "figure.basketball")
                    }
                    .padding(.horizontal, 20)

                    // coach feedback
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "quote.opening").foregroundStyle(Theme.primary)
                            Text("Coach Kyrie AI")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(Theme.textPrimary)
                        }
                        Text(coachLine)
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .glassCard()
                    .padding(.horizontal, 20)

                    PrimaryButton(title: "Done", icon: "checkmark") { onDone() }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                }
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) { appear = true }
        }
    }
}
