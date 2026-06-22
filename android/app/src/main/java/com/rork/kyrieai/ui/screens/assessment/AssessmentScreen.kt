package com.rork.kyrieai.ui.screens.assessment

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CenterFocusWeak
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.FiberManualRecord
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.SportsBasketball
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rork.kyrieai.data.DrillSample
import com.rork.kyrieai.data.KyrieViewModel
import com.rork.kyrieai.data.Move
import com.rork.kyrieai.data.MoveCatalog
import com.rork.kyrieai.data.ScoreEngine
import com.rork.kyrieai.data.SkillCategory
import com.rork.kyrieai.ui.components.ArenaBackground
import com.rork.kyrieai.ui.components.CameraPlaceholder
import com.rork.kyrieai.ui.components.GlassCard
import com.rork.kyrieai.ui.components.PrimaryButton
import com.rork.kyrieai.ui.components.TagPill
import com.rork.kyrieai.ui.screens.onboarding.systemPadding
import com.rork.kyrieai.ui.theme.KT
import com.rork.kyrieai.util.Haptics
import kotlinx.coroutines.delay

private enum class Phase { INTRO, SCANNING, BUILDING, RESULT }

@Composable
fun AssessmentScreen(vm: KyrieViewModel) {
    val profile = vm.profile.collectAsStateWithLifecycle().value ?: return
    var phase by remember { mutableStateOf(Phase.INTRO) }
    var moveIndex by remember { mutableIntStateOf(0) }
    val samples = remember { mutableListOf<DrillSample>() }
    var categories by remember { mutableStateOf<Map<SkillCategory, Int>>(emptyMap()) }
    var score by remember { mutableIntStateOf(0) }
    val moves = MoveCatalog.assessmentMoves

    Box(modifier = Modifier.fillMaxSize().background(KT.background)) {
        ArenaBackground()
        AnimatedContent(
            targetState = phase,
            transitionSpec = { fadeIn() togetherWith fadeOut() },
            label = "phase",
        ) { current ->
            when (current) {
                Phase.INTRO -> IntroPhase(
                    moves = moves,
                    onBegin = {
                        moveIndex = 0
                        samples.clear()
                        phase = Phase.SCANNING
                    },
                    onSkip = { vm.skipAssessment() },
                )
                Phase.SCANNING -> ScanPhase(
                    move = moves[moveIndex],
                    index = moveIndex,
                    total = moves.size,
                    onComplete = { quality, reaction ->
                        samples.add(DrillSample(moves[moveIndex], quality, reaction))
                        if (moveIndex + 1 < moves.size) {
                            moveIndex += 1
                        } else {
                            val cats = ScoreEngine.categoryScores(samples, profile.skillLevel.baseScore)
                            categories = cats
                            score = ScoreEngine.ballHandlerScore(cats)
                            phase = Phase.BUILDING
                        }
                    },
                )
                Phase.BUILDING -> PlanBuildingPhase(profile.firstName) { phase = Phase.RESULT }
                Phase.RESULT -> AssessmentResult(
                    profile = profile,
                    categories = categories,
                    score = score,
                    onContinue = { vm.commitAssessment(categories, score) },
                )
            }
        }
    }
}

@Composable
private fun IntroPhase(moves: List<Move>, onBegin: () -> Unit, onSkip: () -> Unit) {
    Column(
        modifier = Modifier.fillMaxSize().systemPadding().padding(horizontal = 22.dp).verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(20.dp),
    ) {
        Spacer(Modifier.height(20.dp))
        Box(contentAlignment = Alignment.Center) {
            Box(Modifier.size(180.dp).blur(30.dp).clip(CircleShape).background(KT.primary.copy(alpha = 0.15f)))
            Icon(Icons.Filled.CenterFocusWeak, contentDescription = null, tint = KT.primary, modifier = Modifier.size(80.dp))
        }
        Text("AI Skill Assessment", color = KT.textPrimary, fontWeight = FontWeight.Black, fontSize = 30.sp, textAlign = TextAlign.Center)
        Text(
            "Coach will call out ${moves.size} moves. Perform each one in front of your camera. Kyrie AI measures control, speed, coordination, reaction, and creativity to build your Ball Handler Score.",
            color = KT.textSecondary, textAlign = TextAlign.Center, fontSize = 14.sp,
        )
        GlassCard(Modifier.fillMaxWidth()) {
            moves.forEachIndexed { i, move ->
                if (i > 0) Spacer(Modifier.height(10.dp))
                Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Filled.SportsBasketball, contentDescription = null, tint = move.difficulty.color, modifier = Modifier.size(20.dp))
                    Spacer(Modifier.size(12.dp))
                    Text(move.name, color = KT.textPrimary, fontWeight = FontWeight.SemiBold, fontSize = 14.sp)
                    Spacer(Modifier.weight(1f))
                    TagPill(move.difficulty.label, move.difficulty.color)
                }
            }
        }
        PrimaryButton("Begin Assessment", icon = Icons.Filled.PlayArrow, onClick = onBegin)
        Text(
            "Skip for now",
            color = KT.textSecondary, fontWeight = FontWeight.Bold, fontSize = 14.sp,
            modifier = Modifier.clickable { Haptics.light(); onSkip() }.padding(14.dp),
        )
        Spacer(Modifier.height(20.dp))
    }
}

@Composable
private fun ScanPhase(move: Move, index: Int, total: Int, onComplete: (Double, Int) -> Unit) {
    // state: 0 ready, 1 countdown/recording, 2 analyzing
    var state by remember(index) { mutableIntStateOf(0) }
    var countdown by remember(index) { mutableIntStateOf(3) }
    val analyze by animateFloatAsState(if (state == 2) 1f else 0f, tween(1600), label = "analyze")

    LaunchedEffect(state) {
        if (state == 1) {
            countdown = 3
            while (countdown > 0) {
                Haptics.beat()
                delay(1000)
                countdown -= 1
            }
            Haptics.success()
            delay(3000)
            state = 2
        } else if (state == 2) {
            delay(1700)
            val quality = ScoreEngine.estimateQuality(move.difficulty)
            val reaction = (280..620).random()
            if (quality > 0.62) Haptics.success() else Haptics.warning()
            delay(900)
            onComplete(quality, reaction)
        }
    }

    Column(
        modifier = Modifier.fillMaxSize().systemPadding().padding(top = 16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(20.dp),
    ) {
        // progress dots
        Row(Modifier.fillMaxWidth().padding(horizontal = 20.dp), horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            (0 until total).forEach { i ->
                Box(
                    Modifier.weight(1f).height(5.dp).clip(CircleShape)
                        .background(if (i <= index) KT.primary else Color.White.copy(alpha = 0.1f))
                )
            }
        }
        Text("MOVE ${index + 1} OF $total", color = KT.textSecondary, fontWeight = FontWeight.Black, fontSize = 12.sp, letterSpacing = 2.sp)
        Text(move.name, color = KT.textPrimary, fontWeight = FontWeight.Black, fontSize = 28.sp)
        Text(move.detail, color = KT.textSecondary, fontSize = 14.sp, textAlign = TextAlign.Center, modifier = Modifier.padding(horizontal = 30.dp))

        CameraPlaceholder(
            modifier = Modifier
                .fillMaxWidth().height(360.dp).padding(horizontal = 20.dp)
                .clip(KT.shapeL)
                .border(1.5.dp, move.difficulty.color.copy(alpha = 0.5f), KT.shapeL),
        ) {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                when (state) {
                    0 -> Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(14.dp)) {
                        Icon(Icons.Filled.SportsBasketball, contentDescription = null, tint = Color.White, modifier = Modifier.size(56.dp))
                        Text("Get in frame & tap Start", color = Color.White.copy(alpha = 0.85f), fontWeight = FontWeight.SemiBold)
                    }
                    1 -> if (countdown > 0) {
                        Text("$countdown", color = Color.White, fontWeight = FontWeight.Black, fontSize = 80.sp)
                    } else {
                        Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(8.dp)) {
                            Text(move.shortName, color = move.difficulty.color, fontWeight = FontWeight.Black, fontSize = 40.sp)
                            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                                Icon(Icons.Filled.FiberManualRecord, contentDescription = null, tint = Color.Red, modifier = Modifier.size(10.dp))
                                Text("Analyzing your reps…", color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.SemiBold)
                            }
                        }
                    }
                    else -> Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        LinearProgressIndicator(progress = { analyze }, color = move.difficulty.color, modifier = Modifier.width(160.dp))
                        Text("Scoring execution…", color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.SemiBold)
                    }
                }
            }
        }

        when (state) {
            0 -> PrimaryButton("Start", icon = Icons.Filled.FiberManualRecord, modifier = Modifier.padding(horizontal = 20.dp)) { state = 1 }
            1 -> Text(if (countdown > 0) "Get ready…" else "Keep going — stay in frame", color = KT.textSecondary, fontWeight = FontWeight.SemiBold, modifier = Modifier.padding(17.dp))
            else -> Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(10.dp), modifier = Modifier.padding(17.dp)) {
                CircularProgressIndicator(color = KT.primary, modifier = Modifier.size(20.dp), strokeWidth = 2.dp)
                Text("Kyrie AI is grading…", color = KT.textSecondary, fontWeight = FontWeight.SemiBold)
            }
        }
        Spacer(Modifier.weight(1f))
    }
}

@Composable
private fun PlanBuildingPhase(firstName: String, onComplete: () -> Unit) {
    val steps = listOf(
        "Analyzing your handle reps",
        "Mapping strengths & weak spots",
        "Matching elite move library",
        "Tuning to your schedule",
        "Finalizing your development plan",
    )
    var stepIndex by remember { mutableIntStateOf(0) }
    val ring by animateFloatAsState(if (stepIndex >= steps.size) 1f else stepIndex.toFloat() / steps.size, tween(600), label = "ring")

    LaunchedEffect(Unit) {
        for (i in steps.indices) {
            stepIndex = i
            Haptics.light()
            delay(880)
        }
        stepIndex = steps.size
        Haptics.success()
        delay(400)
        onComplete()
    }

    Column(
        modifier = Modifier.fillMaxSize().systemPadding().padding(horizontal = 28.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(40.dp),
    ) {
        Spacer(Modifier.weight(1f))
        Box(contentAlignment = Alignment.Center, modifier = Modifier.size(220.dp)) {
            Box(Modifier.size(200.dp).blur(40.dp).clip(CircleShape).background(KT.primary.copy(alpha = 0.18f)))
            com.rork.kyrieai.ui.components.ScoreRing(progress = ring, size = 180, lineWidth = 10) {}
            Icon(Icons.Filled.SportsBasketball, contentDescription = null, tint = KT.primary, modifier = Modifier.size(76.dp).scale(1f).alpha(1f))
        }
        Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Text("COACH IS BUILDING\nYOUR PLAN", color = KT.textPrimary, fontWeight = FontWeight.Black, fontSize = 26.sp, textAlign = TextAlign.Center)
            Text("Crafting a plan for $firstName", color = KT.textSecondary, fontSize = 14.sp)
        }
        GlassCard(Modifier.fillMaxWidth()) {
            steps.forEachIndexed { idx, step ->
                if (idx > 0) Spacer(Modifier.height(14.dp))
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(14.dp)) {
                    Box(Modifier.size(24.dp), contentAlignment = Alignment.Center) {
                        when {
                            idx < stepIndex -> {
                                Box(Modifier.size(24.dp).clip(CircleShape).background(KT.energy))
                                Icon(Icons.Filled.Check, contentDescription = null, tint = KT.onAccent, modifier = Modifier.size(14.dp))
                            }
                            idx == stepIndex -> CircularProgressIndicator(color = KT.primary, modifier = Modifier.size(20.dp), strokeWidth = 2.dp)
                            else -> Box(Modifier.size(24.dp).clip(CircleShape).border(2.dp, KT.textTertiary, CircleShape))
                        }
                    }
                    Text(step, color = if (idx <= stepIndex) KT.textPrimary else KT.textTertiary, fontWeight = if (idx == stepIndex) FontWeight.Bold else FontWeight.SemiBold, fontSize = 14.sp)
                }
            }
        }
        Spacer(Modifier.weight(1f))
    }
}
