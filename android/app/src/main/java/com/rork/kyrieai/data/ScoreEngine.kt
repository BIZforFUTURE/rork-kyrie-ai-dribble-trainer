package com.rork.kyrieai.data

import kotlin.math.roundToInt
import kotlin.random.Random

data class DrillSample(
    val move: Move,
    val quality: Double,
    val reactionMs: Int,
)

object ScoreEngine {
    /** Derive category scores (0..100) from assessment samples + declared baseline. */
    fun categoryScores(samples: List<DrillSample>, baseline: Int): Map<SkillCategory, Int> {
        val totals = mutableMapOf<SkillCategory, Double>()
        val counts = mutableMapOf<SkillCategory, Double>()
        for (sample in samples) {
            for (skill in sample.move.primarySkills) {
                totals[skill] = (totals[skill] ?: 0.0) + sample.quality
                counts[skill] = (counts[skill] ?: 0.0) + 1
            }
        }
        val result = mutableMapOf<SkillCategory, Int>()
        for (category in SkillCategory.entries) {
            val c = counts[category]
            val avg = if (c != null && c > 0) totals[category]!! / c else 0.55
            val measured = avg * 100
            val blended = baseline * 0.45 + measured * 0.55
            val jitter = ((category.label.length * 7) % 9) - 4
            result[category] = (blended + jitter).toInt().coerceIn(20, 99)
        }
        return result
    }

    fun ballHandlerScore(categories: Map<SkillCategory, Int>): Int {
        if (categories.isEmpty()) return 0
        val weights = mapOf(
            SkillCategory.CONTROL to 1.3, SkillCategory.SPEED to 1.0, SkillCategory.COORDINATION to 1.1,
            SkillCategory.REACTION to 1.0, SkillCategory.CREATIVITY to 0.9, SkillCategory.WEAK_HAND to 1.05,
        )
        var weighted = 0.0
        var weightSum = 0.0
        for ((cat, score) in categories) {
            val w = weights[cat] ?: 1.0
            weighted += score * w
            weightSum += w
        }
        return (weighted / weightSum).roundToInt()
    }

    /** A simulated quality estimate when no camera is available. */
    fun estimateQuality(difficulty: MoveDifficulty): Double {
        val base = Random.nextDouble(0.55, 0.92)
        val penalty = when (difficulty) {
            MoveDifficulty.BASIC -> 0.0
            MoveDifficulty.INTERMEDIATE -> 0.06
            MoveDifficulty.ADVANCED -> 0.12
            MoveDifficulty.SIGNATURE -> 0.18
        }
        return (base - penalty).coerceAtLeast(0.3)
    }

    data class SessionGrade(val accuracy: Int, val avgReactionMs: Int, val xp: Int)

    fun gradeSession(samples: List<DrillSample>, mode: TrainingMode): SessionGrade {
        if (samples.isEmpty()) return SessionGrade(0, 0, 0)
        val avgQuality = samples.sumOf { it.quality } / samples.size
        val accuracy = (avgQuality * 100).toInt().coerceIn(35, 99)
        val avgReaction = samples.sumOf { it.reactionMs } / samples.size
        val baseXP = mode.defaultReps * 10
        val bonus = (avgQuality * 80).toInt()
        return SessionGrade(accuracy, avgReaction, baseXP + bonus)
    }
}
