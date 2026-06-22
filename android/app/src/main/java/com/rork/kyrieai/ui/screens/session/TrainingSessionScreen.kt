package com.rork.kyrieai.ui.screens.session

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rork.kyrieai.data.DrillSample
import com.rork.kyrieai.data.Move
import com.rork.kyrieai.data.ScoreEngine
import com.rork.kyrieai.data.TrainingMode
import com.rork.kyrieai.ui.components.CameraPlaceholder
import com.rork.kyrieai.ui.screens.onboarding.systemPadding
import com.rork.kyrieai.ui.theme.KT
import com.rork.kyrieai.util.Haptics
import com.rork.kyrieai.util.VoiceCoach
import kotlinx.coroutines.delay
import kotlin.math.max
import kotlin.random.Random

private enum class Phase { COUNTDOWN, ACTIVE, FINISHED }

@Composable
fun TrainingSessionScreen(
    mode: TrainingMode,
    onFinish: (accuracy: Int, reactionMs: Int, xp: Int, moves: Int, duration: Int) -> Unit,
    onClose: () -> Unit,
) {
    val context = LocalContext.current
    val voice = remember { VoiceCoach(context) }
    DisposableEffect(Unit) { onDispose { voice.shutdown() } }

    var phase by remember { mutableStateOf(Phase.COUNTDOWN) }
    var countdown by remember { mutableIntStateOf(3) }
    var movesDone by remember { mutableIntStateOf(0) }
    var combo by remember { mutableIntStateOf(0) }
    var currentMove by remember { mutableStateOf<Move?>(null) }
    var timeRemaining by remember { mutableIntStateOf(4) }
    var moveDuration by remember { mutableIntStateOf(4) }
    var feedbackText by remember { mutableStateOf("") }
    var feedbackPositive by remember { mutableStateOf(true) }
    var showFeedback by remember { mutableStateOf(false) }
    var perceived by remember { mutableStateOf(0.8) }

    val totalMoves = mode.defaultReps
    val samples = remember { mutableListOf<DrillSample>() }

    var resultAccuracy by remember { mutableIntStateOf(0) }
    var resultReaction by remember { mutableIntStateOf(0) }
    var resultXP by remember { mutableIntStateOf(0) }

    fun commitMove() {
        val move = currentMove ?: return
        val quality = (perceived + combo * 0.005 + Random.nextDouble(-0.08, 0.08)).coerceIn(0.4, 0.99)
        if (quality > 0.6) combo += 1 else combo = 0
        samples.add(DrillSample(move, quality, 0))
        val (positive, line) = when {
            quality > 0.82 -> true to listOf("Filthy!", "Ankles!", "Ice cold!", "That's the one!", "Unreal handle!").random()
            quality > 0.62 -> true to listOf("Good rep", "Clean", "Keep that rhythm", "Nice work").random()
            else -> false to "Next rep"
        }
        feedbackText = line; feedbackPositive = positive; showFeedback = true
        if (positive) Haptics.success() else Haptics.tap()
        voice.feedback(line)
    }

    // countdown loop
    LaunchedEffect(Unit) {
        countdown = 3
        while (countdown > 0) {
            Haptics.beat(); voice.command("$countdown", 0.5f)
            delay(1000); countdown -= 1
        }
        Haptics.success(); voice.command("Let's go!")
        phase = Phase.ACTIVE
    }

    // active loop
    LaunchedEffect(phase) {
        if (phase != Phase.ACTIVE) return@LaunchedEffect
        while (movesDone < totalMoves) {
            moveDuration = max(2, 4 - movesDone / 5)
            timeRemaining = moveDuration
            val move = mode.moves.random()
            currentMove = move
            Haptics.heavy(); voice.command(move.shortName)
            while (timeRemaining > 0) {
                delay(1000); timeRemaining -= 1
            }
            commitMove()
            movesDone += 1
            delay(150)
        }
        // finish
        val grade = ScoreEngine.gradeSession(samples, mode)
        resultAccuracy = grade.accuracy; resultReaction = grade.avgReactionMs; resultXP = grade.xp
        Haptics.success()
        val closer = when {
            grade.accuracy >= 80 -> "Session complete. Elite work today."
            grade.accuracy >= 60 -> "Session complete. Solid work — keep grinding."
            else -> "Session complete. Trust the reps, we go again."
        }
        voice.command(closer, 0.52f)
        phase = Phase.FINISHED
    }

    // auto-hide feedback
    LaunchedEffect(feedbackText, showFeedback) {
        if (showFeedback) { delay(1400); showFeedback = false }
    }

    Box(Modifier.fillMaxSize().background(Color.Black)) {
        CameraPlaceholder(Modifier.fillMaxSize())
        Box(Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.45f)))

        when (phase) {
            Phase.COUNTDOWN -> CountdownOverlay(mode, countdown, onClose)
            Phase.ACTIVE -> ActiveOverlay(
                mode, movesDone, totalMoves, combo, currentMove, timeRemaining, moveDuration,
                showFeedback, feedbackText, feedbackPositive,
                onHit = { combo += 1; perceived = (perceived + 0.03).coerceAtMost(1.0); if (combo % 5 == 0) Haptics.heavy() else Haptics.beat() },
                onClose = onClose,
            )
            Phase.FINISHED -> SessionResult(mode, resultAccuracy, resultReaction, samples.size, resultXP) {
                onFinish(resultAccuracy, resultReaction, resultXP, samples.size, max(60, totalMoves * moveDuration))
            }
        }
    }
}

@Composable
private fun CountdownOverlay(mode: TrainingMode, countdown: Int, onClose: () -> Unit) {
    Column(Modifier.fillMaxSize().systemPadding().padding(20.dp), horizontalAlignment = Alignment.CenterHorizontally) {
        Spacer(Modifier.weight(1f))
        Text(mode.title.uppercase(), color = mode.tint, fontWeight = FontWeight.Black, fontSize = 12.sp, letterSpacing = 3.sp)
        Text(if (countdown > 0) "$countdown" else "GO", color = Color.White, fontWeight = FontWeight.Black, fontSize = 120.sp)
        Text("Get the ball in your hands & step into frame", color = Color.White.copy(alpha = 0.7f), fontSize = 14.sp, textAlign = TextAlign.Center)
        Spacer(Modifier.weight(1f))
        CloseButton(onClose)
        Spacer(Modifier.height(30.dp))
    }
}

@Composable
private fun ActiveOverlay(
    mode: TrainingMode,
    movesDone: Int,
    totalMoves: Int,
    combo: Int,
    currentMove: Move?,
    timeRemaining: Int,
    moveDuration: Int,
    showFeedback: Boolean,
    feedbackText: String,
    feedbackPositive: Boolean,
    onHit: () -> Unit,
    onClose: () -> Unit,
) {
    Column(Modifier.fillMaxSize().systemPadding()) {
        Row(Modifier.fillMaxWidth().padding(horizontal = 20.dp, vertical = 8.dp), verticalAlignment = Alignment.CenterVertically) {
            CloseButton(onClose)
            Spacer(Modifier.weight(1f))
            HudStat("$movesDone/$totalMoves", "MOVES", Color.White)
            Spacer(Modifier.weight(1f))
            HudStat("x$combo", "COMBO", KT.energy)
            Spacer(Modifier.weight(1f))
            Spacer(Modifier.size(44.dp))
        }
        // progress bar
        Box(Modifier.fillMaxWidth().padding(horizontal = 20.dp, vertical = 10.dp).height(6.dp).clip(CircleShape).background(Color.White.copy(alpha = 0.12f))) {
            Box(Modifier.fillMaxWidth(movesDone.toFloat() / max(1, totalMoves)).height(6.dp).clip(CircleShape).background(mode.tint))
        }
        Spacer(Modifier.weight(1f))
        if (showFeedback) {
            Row(
                modifier = Modifier.align(Alignment.CenterHorizontally).clip(CircleShape)
                    .background(if (feedbackPositive) KT.energy else KT.pink).padding(horizontal = 16.dp, vertical = 10.dp),
                verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                Text(feedbackText, color = if (feedbackPositive) KT.onAccent else Color.White, fontWeight = FontWeight.Black, fontSize = 14.sp)
            }
            Spacer(Modifier.height(12.dp))
        }
        // big callout
        currentMove?.let { move ->
            Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(18.dp)) {
                TimerRing(timeRemaining, moveDuration, mode.tint)
                AnimatedContent(targetState = move.shortName, transitionSpec = { (scaleIn() + fadeIn()) togetherWith fadeOut() }, label = "callout") { name ->
                    Text(name, color = Color.White, fontWeight = FontWeight.Black, fontSize = 52.sp)
                }
                Text(move.detail, color = Color.White.copy(alpha = 0.8f), fontSize = 14.sp, textAlign = TextAlign.Center, modifier = Modifier.padding(horizontal = 40.dp))
            }
        }
        Spacer(Modifier.weight(1f))
        // hit button
        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 30.dp).padding(bottom = 40.dp)
                .clip(CircleShape).background(mode.tint).clickable { onHit() }.padding(vertical = 18.dp),
            horizontalArrangement = Arrangement.Center, verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(Icons.Filled.CheckCircle, contentDescription = null, tint = KT.onAccent, modifier = Modifier.size(22.dp))
            Spacer(Modifier.size(10.dp))
            Text("Nailed it", color = KT.onAccent, fontWeight = FontWeight.Bold, fontSize = 17.sp)
        }
    }
}

@Composable
private fun HudStat(value: String, label: String, valueColor: Color) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(value, color = valueColor, fontWeight = FontWeight.Black, fontSize = 16.sp)
        Text(label, color = Color.White.copy(alpha = 0.6f), fontWeight = FontWeight.Bold, fontSize = 10.sp)
    }
}

@Composable
private fun TimerRing(remaining: Int, total: Int, tint: Color) {
    val progress by animateFloatAsState(remaining.toFloat() / max(1, total), tween(1000), label = "timer")
    Box(Modifier.size(90.dp), contentAlignment = Alignment.Center) {
        Canvas(Modifier.fillMaxSize()) {
            val sw = 6.dp.toPx()
            drawArc(Color.White.copy(alpha = 0.15f), 0f, 360f, false, style = Stroke(sw))
            drawArc(tint, -90f, 360f * progress, false, style = Stroke(sw, cap = StrokeCap.Round))
        }
        Text("$remaining", color = Color.White, fontWeight = FontWeight.Black, fontSize = 28.sp)
    }
}

@Composable
private fun CloseButton(onClose: () -> Unit) {
    Box(
        Modifier.size(44.dp).clip(CircleShape).background(Color.White.copy(alpha = 0.12f)).clickable { onClose() },
        contentAlignment = Alignment.Center,
    ) { Icon(Icons.Filled.Close, contentDescription = "Close", tint = Color.White, modifier = Modifier.size(20.dp)) }
}
