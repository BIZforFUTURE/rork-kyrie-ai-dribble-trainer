//
//  SessionRecord.swift
//  KyrieAI
//
//  A completed training session stored to the player's history.
//

import Foundation
import SwiftData

@Model
final class SessionRecord {
    var id: UUID
    var modeID: String
    var modeTitle: String
    var date: Date
    var durationSeconds: Int
    var movesCompleted: Int
    var accuracy: Int        // 0...100 execution quality
    var avgReactionMs: Int
    var xpEarned: Int

    init(
        modeID: String,
        modeTitle: String,
        date: Date = Date(),
        durationSeconds: Int,
        movesCompleted: Int,
        accuracy: Int,
        avgReactionMs: Int,
        xpEarned: Int
    ) {
        self.id = UUID()
        self.modeID = modeID
        self.modeTitle = modeTitle
        self.date = date
        self.durationSeconds = durationSeconds
        self.movesCompleted = movesCompleted
        self.accuracy = accuracy
        self.avgReactionMs = avgReactionMs
        self.xpEarned = xpEarned
    }
}
