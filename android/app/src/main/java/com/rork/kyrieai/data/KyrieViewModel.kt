package com.rork.kyrieai.data

import android.app.Activity
import android.app.Application
import android.content.Context
import androidx.lifecycle.AndroidViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.serialization.json.Json
import java.util.Calendar
import java.util.UUID
import kotlin.math.max

/** Holds the persisted player profile and subscription state. */
class KyrieViewModel(app: Application) : AndroidViewModel(app) {

    private val prefs = app.getSharedPreferences("kyrie_ai", Context.MODE_PRIVATE)
    private val json = Json { ignoreUnknownKeys = true }

    private val _profile = MutableStateFlow(loadProfile())
    val profile: StateFlow<PlayerProfile?> = _profile.asStateFlow()

    private val _isPremium = MutableStateFlow(prefs.getBoolean("premium", false))
    val isPremium: StateFlow<Boolean> = _isPremium.asStateFlow()

    /** Google Play Billing. Entitlement is driven by real Play purchases. */
    val billing = BillingManager(app) { active -> setPremium(active) }
    val billingStatus: StateFlow<String?> = billing.status

    init {
        billing.start()
    }

    /** Launches the Play purchase flow for the given subscription product. */
    fun purchase(activity: Activity, productId: String) {
        billing.purchase(activity, productId)
    }

    /** Re-checks Play entitlements (used for "Restore purchases"). */
    fun restorePurchases() {
        billing.queryPurchases()
    }

    fun clearBillingStatus() {
        billing.clearStatus()
    }

    fun priceFor(productId: String): String? = billing.formattedPrice(productId)

    private fun loadProfile(): PlayerProfile? {
        val raw = prefs.getString("profile", null) ?: return null
        return runCatching { json.decodeFromString<PlayerProfile>(raw) }.getOrNull()
    }

    private fun persist(profile: PlayerProfile?) {
        _profile.value = profile
        if (profile == null) {
            prefs.edit().remove("profile").apply()
        } else {
            prefs.edit().putString("profile", json.encodeToString(profile)).apply()
        }
    }

    fun update(transform: (PlayerProfile) -> PlayerProfile) {
        val current = _profile.value ?: return
        persist(transform(current))
    }

    fun setPremium(value: Boolean) {
        _isPremium.value = value
        prefs.edit().putBoolean("premium", value).apply()
    }

    fun commitOnboarding(draft: OnboardingDraft) {
        val profile = PlayerProfile(
            name = draft.name.trim(),
            age = draft.age,
            heightInches = draft.heightInches,
            skillLevel = draft.skillLevel ?: SkillLevel.BEGINNER,
            position = draft.position ?: Position.POINT_GUARD,
            dominantHand = draft.dominantHand ?: Hand.RIGHT,
            goals = draft.goals.toList(),
            trainingDays = draft.trainingDays.toList(),
            specificRequests = draft.specificRequests.trim(),
            hasOnboarded = true,
        )
        persist(profile)
    }

    fun skipAssessment() {
        update { p ->
            var updated = p
            val base = p.skillLevel.baseScore
            for (cat in SkillCategory.entries) updated = updated.withScore(base, cat)
            updated.copy(ballHandlerScore = base, hasAssessment = true)
        }
    }

    fun commitAssessment(categories: Map<SkillCategory, Int>, score: Int) {
        update { p ->
            var updated = p
            for (cat in SkillCategory.entries) updated = updated.withScore(categories[cat] ?: 50, cat)
            updated.copy(ballHandlerScore = score, hasAssessment = true)
        }
    }

    fun recordSession(mode: TrainingMode, accuracy: Int, reactionMs: Int, xp: Int, movesCompleted: Int, durationSeconds: Int) {
        update { p ->
            val record = SessionRecord(
                id = UUID.randomUUID().toString(),
                modeID = mode.id,
                modeTitle = mode.title,
                date = System.currentTimeMillis(),
                durationSeconds = durationSeconds,
                movesCompleted = movesCompleted,
                accuracy = accuracy,
                avgReactionMs = reactionMs,
                xpEarned = xp,
            )
            var updated = p.copy(
                sessions = p.sessions + record,
                totalXP = p.totalXP + xp,
            )
            // streak
            val (streak, last) = computeStreak(p.lastTrainedAt, p.currentStreak)
            updated = updated.copy(
                currentStreak = streak,
                longestStreak = max(p.longestStreak, streak),
                lastTrainedAt = last,
            )
            // nudge focus category scores
            val gain = if (accuracy >= 75) 2 else 1
            for (cat in mode.focus) updated = updated.withScore(updated.score(cat) + gain, cat)
            updated.copy(ballHandlerScore = ScoreEngine.ballHandlerScore(updated.categoryScores))
        }
    }

    private fun computeStreak(lastTrainedAt: Long?, currentStreak: Int): Pair<Int, Long> {
        val now = System.currentTimeMillis()
        if (lastTrainedAt == null) return 1 to now
        val cal = Calendar.getInstance()
        cal.timeInMillis = lastTrainedAt
        val lastDay = cal.get(Calendar.DAY_OF_YEAR)
        val lastYear = cal.get(Calendar.YEAR)
        cal.timeInMillis = now
        val today = cal.get(Calendar.DAY_OF_YEAR)
        val thisYear = cal.get(Calendar.YEAR)
        return when {
            lastYear == thisYear && lastDay == today -> currentStreak to now
            (lastYear == thisYear && lastDay == today - 1) ||
                (thisYear == lastYear + 1 && today == 1) -> (currentStreak + 1) to now
            else -> 1 to now
        }
    }

    fun updateStats(age: Int, heightInches: Int) {
        update { it.copy(age = age, heightInches = heightInches) }
    }

    fun reset() {
        persist(null)
    }
}
