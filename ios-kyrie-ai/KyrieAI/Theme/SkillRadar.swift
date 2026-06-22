//
//  SkillRadar.swift
//  KyrieAI
//
//  Hexagonal radar chart visualizing the six skill categories.
//

import SwiftUI

struct SkillRadar: View {
    let scores: [SkillCategory: Int]
    @State private var progress: CGFloat = 0

    private let categories = SkillCategory.allCases

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = min(geo.size.width, geo.size.height) / 2 - 34

            ZStack {
                // grid rings
                ForEach(1...4, id: \.self) { ring in
                    polygon(center: center, radius: radius * CGFloat(ring) / 4)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                }
                // spokes
                ForEach(0..<categories.count, id: \.self) { i in
                    Path { p in
                        p.move(to: center)
                        p.addLine(to: point(center: center, radius: radius, index: i))
                    }
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                }
                // data shape
                dataPath(center: center, radius: radius)
                    .fill(Theme.primary.opacity(0.22))
                dataPath(center: center, radius: radius)
                    .stroke(Theme.fireGradient, style: StrokeStyle(lineWidth: 2.5, lineJoin: .round))
                // vertices
                ForEach(0..<categories.count, id: \.self) { i in
                    let v = Double(scores[categories[i]] ?? 0) / 100
                    let pt = point(center: center, radius: radius * CGFloat(v) * progress, index: i)
                    Circle()
                        .fill(categories[i].color)
                        .frame(width: 8, height: 8)
                        .position(pt)
                }
                // labels
                ForEach(0..<categories.count, id: \.self) { i in
                    let pt = point(center: center, radius: radius + 22, index: i)
                    Text(categories[i].rawValue)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Theme.textSecondary)
                        .position(pt)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.7)) { progress = 1 }
        }
    }

    private func point(center: CGPoint, radius: CGFloat, index: Int) -> CGPoint {
        let angle = (CGFloat(index) / CGFloat(categories.count)) * 2 * .pi - .pi / 2
        return CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
    }

    private func polygon(center: CGPoint, radius: CGFloat) -> Path {
        Path { p in
            for i in 0..<categories.count {
                let pt = point(center: center, radius: radius, index: i)
                if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
            }
            p.closeSubpath()
        }
    }

    private func dataPath(center: CGPoint, radius: CGFloat) -> Path {
        Path { p in
            for i in 0..<categories.count {
                let v = Double(scores[categories[i]] ?? 0) / 100
                let pt = point(center: center, radius: radius * CGFloat(v) * progress, index: i)
                if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
            }
            p.closeSubpath()
        }
    }
}
