package com.rork.kyrieai.ui.screens.onboarding

import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.CameraEnhance
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.PanTool
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material.icons.filled.ShowChart
import androidx.compose.material.icons.filled.SportsBasketball
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.Verified
import androidx.compose.material3.Icon
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rork.kyrieai.data.Hand
import com.rork.kyrieai.data.OnboardingDraft
import com.rork.kyrieai.data.Position
import com.rork.kyrieai.data.SkillLevel
import com.rork.kyrieai.data.TrainingGoal
import com.rork.kyrieai.data.Weekday
import com.rork.kyrieai.data.Availability
import com.rork.kyrieai.ui.components.DayToggle
import com.rork.kyrieai.ui.components.GlassCard
import com.rork.kyrieai.ui.components.SelectRow
import com.rork.kyrieai.ui.theme.KT
import com.rork.kyrieai.util.Haptics

@Composable
fun StepScaffold(
    eyebrow: String,
    title: String,
    subtitle: String? = null,
    content: @Composable () -> Unit,
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 22.dp)
            .padding(top = 24.dp, bottom = 20.dp),
        verticalArrangement = Arrangement.spacedBy(22.dp),
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Text(eyebrow.uppercase(), color = KT.primary, fontWeight = FontWeight.Black, fontSize = 12.sp, letterSpacing = 2.sp)
            Text(title, color = KT.textPrimary, fontWeight = FontWeight.Black, fontSize = 30.sp)
            if (subtitle != null) Text(subtitle, color = KT.textSecondary, fontSize = 14.sp)
        }
        content()
    }
}

@Composable
fun WelcomeStep() {
    val t = rememberInfiniteTransition(label = "welcome")
    val pulse by t.animateFloat(0.9f, 1.1f, infiniteRepeatable(tween(3200), RepeatMode.Reverse), label = "pulse")
    Column(
        modifier = Modifier.fillMaxSize().padding(horizontal = 22.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(26.dp),
    ) {
        Spacer(Modifier.height(8.dp))
        Box(contentAlignment = Alignment.Center, modifier = Modifier.weight(1f)) {
            Box(Modifier.size(240.dp).scale(pulse).blur(40.dp).clip(CircleShape).background(KT.primary.copy(alpha = 0.18f)))
            Box(
                Modifier.size(150.dp).clip(KT.shapeL).background(KT.fireGradient),
                contentAlignment = Alignment.Center,
            ) {
                Icon(Icons.Filled.SportsBasketball, contentDescription = null, tint = Color.White, modifier = Modifier.size(80.dp))
            }
        }
        Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(14.dp)) {
            Text("KYRIE AI", color = KT.textPrimary, fontWeight = FontWeight.Black, fontSize = 40.sp, letterSpacing = 2.sp)
            Text(
                "Your personal AI ball-handling coach. Train your handle, footwork, and creativity like an elite guard — every single day.",
                color = KT.textSecondary, textAlign = TextAlign.Center, fontSize = 16.sp,
                modifier = Modifier.padding(horizontal = 16.dp),
            )
        }
        Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            FeaturePill(Icons.Filled.CameraEnhance, "Camera AI")
            FeaturePill(Icons.Filled.ShowChart, "Tracked")
            FeaturePill(Icons.Filled.LocalFireDepartment, "Daily")
        }
        Spacer(Modifier.weight(1f))
    }
}

@Composable
private fun FeaturePill(icon: ImageVector, text: String) {
    Row(
        modifier = Modifier
            .clip(CircleShape)
            .background(KT.surface)
            .border(1.dp, KT.stroke, CircleShape)
            .padding(horizontal = 12.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(6.dp),
    ) {
        Icon(icon, contentDescription = null, tint = KT.textPrimary, modifier = Modifier.size(14.dp))
        Text(text, color = KT.textPrimary, fontWeight = FontWeight.SemiBold, fontSize = 12.sp)
    }
}

@Composable
fun NameStep(draft: OnboardingDraft) {
    var focused by remember { mutableStateOf(false) }
    StepScaffold("Step 1", "What should\nCoach call you?", "We'll personalize your training around your name.") {
        BasicTextField(
            value = draft.name,
            onValueChange = { draft.name = it },
            textStyle = TextStyle(color = KT.textPrimary, fontSize = 22.sp, fontWeight = FontWeight.Bold),
            cursorBrush = SolidColor(KT.primary),
            modifier = Modifier
                .fillMaxWidth()
                .clip(KT.shapeM)
                .background(KT.surface)
                .border(1.5.dp, if (focused) KT.primary.copy(alpha = 0.6f) else KT.stroke, KT.shapeM)
                .padding(18.dp),
            decorationBox = { inner ->
                if (draft.name.isEmpty()) Text("Your name", color = KT.textTertiary, fontSize = 22.sp, fontWeight = FontWeight.Bold)
                inner()
            },
        )
    }
}

@Composable
fun PhysicalsStep(draft: OnboardingDraft) {
    StepScaffold("Step 2", "Your build", "Coach tailors footwork and handle height to your frame.") {
        Column(verticalArrangement = Arrangement.spacedBy(18.dp)) {
            StepperCard("Age", "${draft.age}", { draft.age = (draft.age - 1).coerceAtLeast(8) }, { draft.age = (draft.age + 1).coerceAtMost(60) })
            Column(
                modifier = Modifier
                    .clip(KT.shapeM).background(KT.surface).border(1.dp, KT.stroke, KT.shapeM).padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text("Height", color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 17.sp)
                    Text("${draft.heightInches / 12}'${draft.heightInches % 12}\"", color = KT.primary, fontWeight = FontWeight.Bold, fontSize = 17.sp)
                }
                Slider(
                    value = draft.heightInches.toFloat(),
                    onValueChange = { draft.heightInches = it.toInt() },
                    valueRange = 48f..84f,
                    colors = SliderDefaults.colors(thumbColor = KT.primary, activeTrackColor = KT.primary),
                )
            }
        }
    }
}

@Composable
private fun StepperCard(title: String, value: String, onMinus: () -> Unit, onPlus: () -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth().clip(KT.shapeM).background(KT.surface).border(1.dp, KT.stroke, KT.shapeM).padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(title, color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 17.sp)
        Spacer(Modifier.weight(1f))
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(18.dp)) {
            CircleIconButton(Icons.Filled.Remove) { Haptics.select(); onMinus() }
            Text(value, color = KT.primary, fontWeight = FontWeight.Black, fontSize = 22.sp)
            CircleIconButton(Icons.Filled.Add) { Haptics.select(); onPlus() }
        }
    }
}

@Composable
private fun CircleIconButton(icon: ImageVector, onClick: () -> Unit) {
    Box(
        modifier = Modifier.size(40.dp).clip(CircleShape).background(KT.surfaceElevated).border(1.dp, KT.stroke, CircleShape).clickable { onClick() },
        contentAlignment = Alignment.Center,
    ) { Icon(icon, contentDescription = null, tint = KT.textPrimary, modifier = Modifier.size(18.dp)) }
}

@Composable
fun SkillStep(draft: OnboardingDraft) {
    StepScaffold("Step 3", "Skill level", "Be honest — Coach calibrates your plan from here.") {
        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            SkillLevel.entries.forEach { level ->
                SelectRow(level.label, draft.skillLevel == level, subtitle = level.subtitle) { draft.skillLevel = level }
            }
        }
    }
}

@Composable
fun PositionStep(draft: OnboardingDraft) {
    StepScaffold("Step 4", "Your position", "Different spots demand different handles.") {
        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            Position.entries.forEach { pos ->
                SelectRow(pos.label, draft.position == pos, subtitle = pos.short) { draft.position = pos }
            }
        }
    }
}

@Composable
fun HandStep(draft: OnboardingDraft) {
    StepScaffold("Step 5", "Dominant hand", "We'll push your weak hand to catch up fast.") {
        Row(horizontalArrangement = Arrangement.spacedBy(14.dp)) {
            Hand.entries.forEach { hand ->
                val selected = draft.dominantHand == hand
                Column(
                    modifier = Modifier
                        .weight(1f)
                        .clip(KT.shapeL)
                        .background(if (selected) KT.primary.copy(alpha = 0.12f) else KT.surface)
                        .border(1.5.dp, if (selected) KT.primary.copy(alpha = 0.6f) else KT.stroke, KT.shapeL)
                        .clickable { Haptics.select(); draft.dominantHand = hand }
                        .padding(vertical = 32.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(14.dp),
                ) {
                    Icon(Icons.Filled.PanTool, contentDescription = null, tint = if (selected) KT.primary else KT.textSecondary, modifier = Modifier.size(44.dp))
                    Text(hand.label, color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 17.sp)
                }
            }
        }
    }
}

@Composable
fun GoalsStep(draft: OnboardingDraft) {
    StepScaffold("Step 6", "Your goals", "Pick everything you want to level up. Choose as many as you like.") {
        LazyVerticalGrid(
            columns = GridCells.Fixed(2),
            modifier = Modifier.height(420.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            items(TrainingGoal.entries) { goal ->
                val selected = draft.goals.contains(goal)
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(70.dp)
                        .clip(KT.shapeM)
                        .background(if (selected) KT.energy.copy(alpha = 0.12f) else KT.surface)
                        .border(1.5.dp, if (selected) KT.energy.copy(alpha = 0.6f) else KT.stroke, KT.shapeM)
                        .clickable {
                            Haptics.select()
                            if (selected) draft.goals.remove(goal) else draft.goals.add(goal)
                        }
                        .padding(14.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                ) {
                    Icon(goal.icon, contentDescription = null, tint = if (selected) KT.energy else KT.textSecondary, modifier = Modifier.size(20.dp))
                    Text(goal.label, color = KT.textPrimary, fontWeight = FontWeight.SemiBold, fontSize = 13.sp)
                }
            }
        }
    }
}

@Composable
fun AvailabilityStep(draft: OnboardingDraft) {
    StepScaffold("Step 7", "Training\ndays", "Pick the days you can put in work. Coach builds your weekly plan around them.") {
        Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
            LazyVerticalGrid(
                columns = GridCells.Fixed(4),
                modifier = Modifier.height(170.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                items(Weekday.entries) { day ->
                    DayToggle(day.short, day.label, draft.trainingDays.contains(day)) {
                        if (draft.trainingDays.contains(day)) draft.trainingDays.remove(day) else draft.trainingDays.add(day)
                    }
                }
            }
            if (draft.trainingDays.isNotEmpty()) {
                Text(
                    "${draft.trainingDays.size} days / week · ${Availability.from(draft.trainingDays.size).subtitle}",
                    color = KT.energy, fontWeight = FontWeight.SemiBold, fontSize = 14.sp,
                )
            }
        }
    }
}

@Composable
fun RequestsStep(draft: OnboardingDraft) {
    var focused by remember { mutableStateOf(false) }
    val suggestions = listOf(
        "Kyrie-style combos", "Tighter, lower handle", "More weak-hand reps",
        "Game-speed moves", "Less footwork drills", "Build finishing creativity",
    )
    StepScaffold("Step 8", "Anything you\nwant from Coach?", "Tell Coach exactly what to emphasize or avoid. This shapes your plan. Optional — skip if you're not sure.") {
        Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
            Box(
                modifier = Modifier
                    .fillMaxWidth().height(150.dp)
                    .clip(KT.shapeM).background(KT.surface)
                    .border(1.5.dp, if (focused) KT.primary.copy(alpha = 0.6f) else KT.stroke, KT.shapeM)
                    .padding(12.dp),
            ) {
                if (draft.specificRequests.isEmpty()) {
                    Text("e.g. Focus on between-the-legs combos and explosive first steps for game situations…", color = KT.textTertiary, fontSize = 15.sp)
                }
                BasicTextField(
                    value = draft.specificRequests,
                    onValueChange = { draft.specificRequests = it },
                    textStyle = TextStyle(color = KT.textPrimary, fontSize = 15.sp),
                    cursorBrush = SolidColor(KT.primary),
                    modifier = Modifier.fillMaxWidth(),
                )
            }
            Text("QUICK ADD", color = KT.textTertiary, fontWeight = FontWeight.Black, fontSize = 10.sp, letterSpacing = 1.5.sp)
            LazyVerticalGrid(
                columns = GridCells.Adaptive(150.dp),
                modifier = Modifier.height(140.dp),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp),
            ) {
                items(suggestions) { s ->
                    Row(
                        modifier = Modifier
                            .clip(CircleShape).background(KT.surface).border(1.dp, KT.stroke, CircleShape)
                            .clickable {
                                Haptics.select()
                                val trimmed = draft.specificRequests.trim()
                                draft.specificRequests = when {
                                    trimmed.isEmpty() -> s
                                    !trimmed.contains(s, ignoreCase = true) -> "$trimmed, $s"
                                    else -> trimmed
                                }
                            }
                            .padding(horizontal = 14.dp, vertical = 10.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp),
                    ) {
                        Icon(Icons.Filled.Add, contentDescription = null, tint = KT.textPrimary, modifier = Modifier.size(14.dp))
                        Text(s, color = KT.textPrimary, fontWeight = FontWeight.SemiBold, fontSize = 14.sp)
                    }
                }
            }
        }
    }
}

@Composable
fun ReadyStep(draft: OnboardingDraft) {
    Column(
        modifier = Modifier.fillMaxSize().padding(horizontal = 22.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(26.dp),
    ) {
        Spacer(Modifier.weight(1f))
        Icon(Icons.Filled.Verified, contentDescription = null, tint = KT.energy, modifier = Modifier.size(84.dp))
        Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(12.dp)) {
            Text("You're set, ${draft.name.split(" ").firstOrNull()?.ifEmpty { "Hooper" } ?: "Hooper"}!", color = KT.textPrimary, fontWeight = FontWeight.Black, fontSize = 28.sp, textAlign = TextAlign.Center)
            Text("Next, Coach runs a quick AI skill assessment to measure your handle and build your custom development plan.", color = KT.textSecondary, textAlign = TextAlign.Center, fontSize = 14.sp)
        }
        GlassCard {
            SummaryRow("Level", draft.skillLevel?.label ?: "—")
            Spacer(Modifier.height(10.dp))
            SummaryRow("Position", draft.position?.label ?: "—")
            Spacer(Modifier.height(10.dp))
            SummaryRow("Focus", "${draft.goals.size} goals")
            Spacer(Modifier.height(10.dp))
            SummaryRow("Schedule", if (draft.trainingDays.isEmpty()) "—" else "${draft.trainingDays.size} days / week")
            if (draft.specificRequests.trim().isNotEmpty()) {
                Spacer(Modifier.height(10.dp))
                SummaryRow("Request", "Noted ✓")
            }
        }
        Spacer(Modifier.weight(1f))
    }
}

@Composable
private fun SummaryRow(label: String, value: String) {
    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
        Text(label, color = KT.textSecondary, fontSize = 14.sp)
        Text(value, color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 14.sp)
    }
}

@Composable
fun RateStep() {
    var filled by remember { mutableStateOf(0) }
    Column(
        modifier = Modifier.fillMaxSize().padding(horizontal = 22.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(30.dp),
    ) {
        Spacer(Modifier.weight(1f))
        Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Text("LOVING THE APP", color = KT.energy, fontWeight = FontWeight.Black, fontSize = 12.sp, letterSpacing = 2.sp)
            Text("Help other hoopers\nfind Kyrie AI", color = KT.textPrimary, fontWeight = FontWeight.Black, fontSize = 30.sp, textAlign = TextAlign.Center)
        }
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            (0 until 5).forEach { index ->
                Icon(
                    Icons.Filled.Star,
                    contentDescription = "Star ${index + 1}",
                    tint = if (index < filled) KT.energy else KT.surfaceElevated,
                    modifier = Modifier
                        .size(44.dp)
                        .scale(if (index < filled) 1f else 0.86f)
                        .clickable { Haptics.success(); filled = index + 1 },
                )
            }
        }
        Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(6.dp)) {
            Text("Join 50,000+ players leveling up their handle", color = KT.textSecondary, textAlign = TextAlign.Center, fontSize = 14.sp)
            Text("Tap the stars to rate Kyrie AI", color = KT.textTertiary, textAlign = TextAlign.Center, fontSize = 12.sp)
        }
        Spacer(Modifier.weight(1f))
    }
}
