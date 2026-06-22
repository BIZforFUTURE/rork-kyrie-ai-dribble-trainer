package com.rork.kyrieai.data

import kotlinx.serialization.Serializable

@Serializable
data class SessionRecord(
    val id: String,
    val modeID: String,
    val modeTitle: String,
    val date: Long,
    val durationSeconds: Int,
    val movesCompleted: Int,
    val accuracy: Int,
    val avgReactionMs: Int,
    val xpEarned: Int,
)

@Serializable
data class PlayerProfile(
    val name: String = "",
    val age: Int = 16,
    val heightInches: Int = 70,
    val skillLevel: SkillLevel = SkillLevel.BEGINNER,
    val position: Position = Position.POINT_GUARD,
    val dominantHand: Hand = Hand.RIGHT,
    val goals: List<TrainingGoal> = emptyList(),
    val trainingDays: List<Weekday> = emptyList(),
    val specificRequests: String = "",
    val hasOnboarded: Boolean = false,
    val hasAssessment: Boolean = false,
    val ballHandlerScore: Int = 0,
    val controlScore: Int = 0,
    val speedScore: Int = 0,
    val coordinationScore: Int = 0,
    val reactionScore: Int = 0,
    val creativityScore: Int = 0,
    val weakHandScore: Int = 0,
    val totalXP: Int = 0,
    val currentStreak: Int = 0,
    val longestStreak: Int = 0,
    val lastTrainedAt: Long? = null,
    val createdAt: Long = System.currentTimeMillis(),
    val sessions: List<SessionRecord> = emptyList(),
) {
    val availability: Availability get() = Availability.from(trainingDays.size)

    val orderedTrainingDays: List<Weekday> get() = trainingDays.sortedBy { it.order }

    val heightFormatted: String get() = "${heightInches / 12}'${heightInches % 12}\""

    val firstName: String get() = name.split(" ").firstOrNull()?.takeIf { it.isNotEmpty() } ?: name

    fun score(category: SkillCategory): Int = when (category) {
        SkillCategory.CONTROL -> controlScore
        SkillCategory.SPEED -> speedScore
        SkillCategory.COORDINATION -> coordinationScore
        SkillCategory.REACTION -> reactionScore
        SkillCategory.CREATIVITY -> creativityScore
        SkillCategory.WEAK_HAND -> weakHandScore
    }

    fun withScore(value: Int, category: SkillCategory): PlayerProfile {
        val v = value.coerceIn(0, 100)
        return when (category) {
            SkillCategory.CONTROL -> copy(controlScore = v)
            SkillCategory.SPEED -> copy(speedScore = v)
            SkillCategory.COORDINATION -> copy(coordinationScore = v)
            SkillCategory.REACTION -> copy(reactionScore = v)
            SkillCategory.CREATIVITY -> copy(creativityScore = v)
            SkillCategory.WEAK_HAND -> copy(weakHandScore = v)
        }
    }

    val categoryScores: Map<SkillCategory, Int>
        get() = SkillCategory.entries.associateWith { score(it) }

    val weakestCategories: List<SkillCategory>
        get() = SkillCategory.entries.sortedBy { score(it) }.take(2)

    val tier: String
        get() = when {
            ballHandlerScore < 50 -> "Rookie Handle"
            ballHandlerScore < 65 -> "Rising Handle"
            ballHandlerScore < 78 -> "Bucket Getter"
            ballHandlerScore < 90 -> "Elite Handle"
            else -> "Untouchable"
        }
}
