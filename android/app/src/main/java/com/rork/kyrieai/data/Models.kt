package com.rork.kyrieai.data

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.DirectionsBike
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.CenterFocusStrong
import androidx.compose.material.icons.filled.DirectionsWalk
import androidx.compose.material.icons.filled.PanTool
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.SelfImprovement
import androidx.compose.material.icons.filled.SportsBasketball
import androidx.compose.material.icons.filled.Timer
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import com.rork.kyrieai.ui.theme.KT

enum class SkillLevel(val label: String, val subtitle: String, val baseScore: Int) {
    BEGINNER("Beginner", "New to organized handles", 42),
    INTERMEDIATE("Intermediate", "Solid fundamentals, building moves", 58),
    ADVANCED("Advanced", "Confident with combos & speed", 72),
    ELITE("Elite", "Tournament / collegiate level", 85),
}

enum class Position(val label: String, val short: String) {
    POINT_GUARD("Point Guard", "PG"),
    SHOOTING_GUARD("Shooting Guard", "SG"),
    SMALL_FORWARD("Small Forward", "SF"),
    POWER_FORWARD("Power Forward", "PF"),
    CENTER("Center", "C"),
}

enum class Hand(val label: String) {
    LEFT("Left"),
    RIGHT("Right"),
}

enum class TrainingGoal(val label: String, val icon: ImageVector) {
    TIGHTER_HANDLE("Tighter Handle", Icons.Filled.PanTool),
    SPEED("Explosive Speed", Icons.Filled.Bolt),
    WEAK_HAND("Weak Hand", Icons.Filled.PanTool),
    CREATIVITY("Creativity & Flair", Icons.Filled.AutoAwesome),
    GAME_MOVES("Game Moves", Icons.Filled.SportsBasketball),
    CONFIDENCE("Confidence", Icons.Filled.LocalFireDepartment),
    FOOTWORK("Footwork", Icons.Filled.DirectionsWalk),
    REACTION("Reaction Time", Icons.Filled.Timer),
}

enum class Availability(val label: String, val subtitle: String) {
    CASUAL("2–3 days / week", "Steady progress"),
    COMMITTED("4–5 days / week", "Fast improvement"),
    DAILY("Every day", "Elite trajectory");

    companion object {
        fun from(dayCount: Int): Availability = when {
            dayCount <= 3 -> CASUAL
            dayCount in 4..5 -> COMMITTED
            else -> DAILY
        }
    }
}

enum class Weekday(val label: String, val short: String) {
    MONDAY("Monday", "Mo"),
    TUESDAY("Tuesday", "Tu"),
    WEDNESDAY("Wednesday", "We"),
    THURSDAY("Thursday", "Th"),
    FRIDAY("Friday", "Fr"),
    SATURDAY("Saturday", "Sa"),
    SUNDAY("Sunday", "Su");

    val order: Int get() = ordinal
}

enum class SkillCategory(val label: String, val icon: ImageVector, val color: Color) {
    CONTROL("Control", Icons.Filled.CenterFocusStrong, KT.primary),
    SPEED("Speed", Icons.Filled.Bolt, KT.gold),
    COORDINATION("Coordination", Icons.Filled.SelfImprovement, KT.info),
    REACTION("Reaction", Icons.Filled.Timer, KT.pink),
    CREATIVITY("Creativity", Icons.Filled.AutoAwesome, KT.purple),
    WEAK_HAND("Weak Hand", Icons.Filled.PanTool, KT.energy),
}

enum class MoveDifficulty(val label: String, val color: Color) {
    BASIC("Basic", KT.info),
    INTERMEDIATE("Intermediate", KT.energy),
    ADVANCED("Advanced", KT.primary),
    SIGNATURE("Signature", KT.purple),
}

data class Move(
    val id: String,
    val name: String,
    val shortName: String,
    val detail: String,
    val difficulty: MoveDifficulty,
    val primarySkills: List<SkillCategory>,
)

object MoveCatalog {
    val all: List<Move> = listOf(
        Move("pound", "Pound Dribble", "POUND", "Hard low control dribble, fingertip command.", MoveDifficulty.BASIC, listOf(SkillCategory.CONTROL)),
        Move("crossover", "Crossover", "CROSS", "Snap the ball low across your body.", MoveDifficulty.BASIC, listOf(SkillCategory.CONTROL, SkillCategory.SPEED)),
        Move("btl", "Between the Legs", "BTL", "Thread it through with rhythm.", MoveDifficulty.INTERMEDIATE, listOf(SkillCategory.COORDINATION, SkillCategory.CONTROL)),
        Move("btb", "Behind the Back", "BEHIND", "Wrap it tight around your hip.", MoveDifficulty.INTERMEDIATE, listOf(SkillCategory.COORDINATION, SkillCategory.CREATIVITY)),
        Move("hesi", "Hesitation", "HESI", "Sell the stop, explode through.", MoveDifficulty.INTERMEDIATE, listOf(SkillCategory.REACTION, SkillCategory.SPEED)),
        Move("inout", "In & Out", "IN-OUT", "Fake the cross, keep it same hand.", MoveDifficulty.INTERMEDIATE, listOf(SkillCategory.CONTROL, SkillCategory.CREATIVITY)),
        Move("changepace", "Change of Pace", "CHANGE", "Slow then burst — break the defender.", MoveDifficulty.INTERMEDIATE, listOf(SkillCategory.SPEED, SkillCategory.REACTION)),
        Move("doublecross", "Double Crossover", "DOUBLE", "Cross, cross back, attack.", MoveDifficulty.ADVANCED, listOf(SkillCategory.COORDINATION, SkillCategory.SPEED)),
        Move("shamgod", "Shamgod", "SHAMGOD", "Push out, pull back with the off hand.", MoveDifficulty.ADVANCED, listOf(SkillCategory.CREATIVITY, SkillCategory.COORDINATION)),
        Move("kyriecombo", "Kyrie Combo", "KYRIE", "Between-legs into behind-back finish.", MoveDifficulty.SIGNATURE, listOf(SkillCategory.CREATIVITY, SkillCategory.COORDINATION, SkillCategory.CONTROL)),
        Move("weakpound", "Weak-Hand Pound", "WEAK", "Off hand only — build that command.", MoveDifficulty.BASIC, listOf(SkillCategory.WEAK_HAND, SkillCategory.CONTROL)),
        Move("spin", "Spin Move", "SPIN", "Plant, spin, protect the ball.", MoveDifficulty.ADVANCED, listOf(SkillCategory.COORDINATION, SkillCategory.CREATIVITY)),
        Move("snatchback", "Snatch Back", "SNATCH", "Drive then rip it back for space.", MoveDifficulty.ADVANCED, listOf(SkillCategory.REACTION, SkillCategory.CREATIVITY)),
    )

    fun move(id: String): Move? = all.firstOrNull { it.id == id }

    val assessmentMoves: List<Move> = listOf("pound", "crossover", "btl", "btb", "hesi", "changepace").mapNotNull { move(it) }
}

data class TrainingMode(
    val id: String,
    val title: String,
    val tagline: String,
    val icon: ImageVector,
    val tint: Color,
    val focus: List<SkillCategory>,
    val moveIDs: List<String>,
    val defaultReps: Int,
) {
    val moves: List<Move> get() = moveIDs.mapNotNull { MoveCatalog.move(it) }
}

object TrainingModeCatalog {
    val all: List<TrainingMode> = listOf(
        TrainingMode("handlelab", "Handle Lab", "Tighten control with relentless reps", Icons.Filled.CenterFocusStrong, KT.primary, listOf(SkillCategory.CONTROL, SkillCategory.COORDINATION), listOf("pound", "crossover", "btl", "btb", "inout", "doublecross"), 12),
        TrainingMode("reaction", "Reaction Training", "Beat the buzzer — train your trigger", Icons.Filled.Timer, KT.pink, listOf(SkillCategory.REACTION, SkillCategory.SPEED), listOf("crossover", "hesi", "changepace", "snatchback", "inout"), 14),
        TrainingMode("gamemoves", "Game Moves", "Counters that break real defenders", Icons.Filled.SportsBasketball, KT.energy, listOf(SkillCategory.CREATIVITY, SkillCategory.SPEED, SkillCategory.CONTROL), listOf("hesi", "changepace", "snatchback", "spin", "kyriecombo"), 10),
        TrainingMode("weakhand", "Weak Hand Development", "Make your off hand a weapon", Icons.Filled.PanTool, KT.info, listOf(SkillCategory.WEAK_HAND, SkillCategory.CONTROL), listOf("weakpound", "crossover", "btl", "inout"), 14),
        TrainingMode("courtvision", "Court Vision", "Handle while reading visual cues", Icons.Filled.Visibility, KT.purple, listOf(SkillCategory.REACTION, SkillCategory.COORDINATION), listOf("pound", "crossover", "btl", "hesi", "changepace"), 12),
        TrainingMode("signature", "Kyrie Signature Lab", "Master elite creative sequences", Icons.Filled.AutoAwesome, KT.gold, listOf(SkillCategory.CREATIVITY, SkillCategory.COORDINATION, SkillCategory.CONTROL), listOf("kyriecombo", "shamgod", "spin", "doublecross", "snatchback"), 8),
    )

    fun mode(id: String): TrainingMode? = all.firstOrNull { it.id == id }

    /** Rotates daily through the modes that target the player's weakest skills. */
    fun mode(dayOfYear: Int, weakest: List<SkillCategory>): TrainingMode {
        val weak = weakest.toSet()
        val matching = all.filter { it.focus.toSet().intersect(weak).isNotEmpty() }
        val pool = matching.ifEmpty { all }
        return pool[dayOfYear % pool.size]
    }
}

data class DailyChallenge(
    val id: String,
    val title: String,
    val detail: String,
    val icon: ImageVector,
    val tint: Color,
    val xp: Int,
    val modeID: String,
)

object ChallengeFactory {
    fun today(dayOfYear: Int): DailyChallenge {
        val pool = listOf(
            DailyChallenge("c1", "60-Second Crossover Storm", "Max clean crossovers in one minute.", Icons.Filled.Bolt, KT.primary, 120, "handlelab"),
            DailyChallenge("c2", "Weak Hand Gauntlet", "Off-hand only — no fumbles allowed.", Icons.Filled.PanTool, KT.info, 150, "weakhand"),
            DailyChallenge("c3", "Reaction Buzzer", "React to 14 random callouts.", Icons.Filled.Timer, KT.pink, 140, "reaction"),
            DailyChallenge("c4", "Signature Flow", "Chain 8 Kyrie-style combos.", Icons.Filled.AutoAwesome, KT.gold, 200, "signature"),
            DailyChallenge("c5", "Game Move Counters", "Read and counter every defender cue.", Icons.Filled.SportsBasketball, KT.energy, 160, "gamemoves"),
        )
        return pool[dayOfYear % pool.size]
    }
}
