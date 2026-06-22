package com.rork.kyrieai.ui.screens.main

import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.PlayCircle
import androidx.compose.material.icons.filled.Schedule
import androidx.compose.material.icons.filled.SportsBasketball
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rork.kyrieai.data.ChallengeFactory
import com.rork.kyrieai.data.PlayerProfile
import com.rork.kyrieai.data.TrainingMode
import com.rork.kyrieai.data.TrainingModeCatalog
import com.rork.kyrieai.ui.components.ArenaBackground
import com.rork.kyrieai.ui.components.GlassCard
import com.rork.kyrieai.ui.components.PressableCard
import com.rork.kyrieai.ui.components.ScoreRing
import com.rork.kyrieai.ui.components.SectionHeader
import com.rork.kyrieai.ui.components.StatChip
import com.rork.kyrieai.ui.screens.onboarding.systemPadding
import com.rork.kyrieai.ui.theme.KT
import java.util.Calendar

@Composable
fun HomeScreen(
    profile: PlayerProfile,
    onLaunch: (TrainingMode, String) -> Unit,
    onUpgrade: () -> Unit,
) {
    val challenge = ChallengeFactory.today(Calendar.getInstance().get(Calendar.DAY_OF_YEAR))
    val recommended = TrainingModeCatalog.all.firstOrNull { mode ->
        mode.focus.toSet().intersect(profile.weakestCategories.toSet()).isNotEmpty()
    } ?: TrainingModeCatalog.all[0]

    Box(Modifier.fillMaxSize()) {
        ArenaBackground()
        Column(
            modifier = Modifier
                .fillMaxSize()
                .systemPadding()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 18.dp)
                .padding(top = 8.dp, bottom = 30.dp),
            verticalArrangement = Arrangement.spacedBy(24.dp),
        ) {
            // greeting
            Row(verticalAlignment = Alignment.CenterVertically) {
                Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(greetingText().uppercase(), color = KT.primary, fontWeight = FontWeight.Black, fontSize = 12.sp, letterSpacing = 2.sp)
                    Text(profile.firstName, color = KT.textPrimary, fontWeight = FontWeight.Black, fontSize = 30.sp)
                }
                Box(
                    Modifier.size(52.dp).clip(CircleShape).background(KT.surface).border(1.dp, KT.stroke, CircleShape),
                    contentAlignment = Alignment.Center,
                ) { Text(profile.position.short, color = KT.primary, fontWeight = FontWeight.Black, fontSize = 16.sp) }
            }

            // hero score
            GlassCard(Modifier.fillMaxWidth()) {
                Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(16.dp)) {
                    Text("BALL HANDLER SCORE", color = KT.textSecondary, fontWeight = FontWeight.Black, fontSize = 12.sp, letterSpacing = 2.sp)
                    ScoreRing(progress = profile.ballHandlerScore / 100f, size = 200, lineWidth = 16) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text("${profile.ballHandlerScore}", color = KT.textPrimary, fontWeight = FontWeight.Black, fontSize = 64.sp)
                            Text(profile.tier, color = KT.primary, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        }
                    }
                    Text("Train today to push your rating higher.", color = KT.textSecondary, fontSize = 12.sp, textAlign = TextAlign.Center)
                }
            }

            // streak row
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                StatChip("${profile.currentStreak}", "Day streak", Modifier.weight(1f), KT.primary, Icons.Filled.LocalFireDepartment)
                StatChip("${profile.totalXP}", "Total XP", Modifier.weight(1f), KT.energy, Icons.Filled.Bolt)
                StatChip("${profile.sessions.size}", "Sessions", Modifier.weight(1f), KT.info, Icons.Filled.SportsBasketball)
            }

            // today's plan
            Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
                SectionHeader("Today's Plan")
                TodaysPlanCard(recommended) { onLaunch(recommended, "Unlock unlimited daily workouts and training") }
            }

            // daily challenge
            Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
                SectionHeader("Daily Challenge")
                PressableCard(onClick = {
                    TrainingModeCatalog.mode(challenge.modeID)?.let { onLaunch(it, "Unlock unlimited daily workouts and training") }
                }) {
                    GlassCard(Modifier.fillMaxWidth()) {
                        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(14.dp)) {
                            Box(Modifier.size(50.dp).clip(CircleShape).background(challenge.tint), contentAlignment = Alignment.Center) {
                                Icon(challenge.icon, contentDescription = null, tint = KT.onAccent, modifier = Modifier.size(24.dp))
                            }
                            Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                                Text(challenge.title, color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                                Text(challenge.detail, color = KT.textSecondary, fontSize = 12.sp)
                            }
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Text("+${challenge.xp}", color = challenge.tint, fontWeight = FontWeight.Black, fontSize = 16.sp)
                                Text("XP", color = KT.textSecondary, fontWeight = FontWeight.Bold, fontSize = 10.sp)
                            }
                        }
                    }
                }
            }

            // training modes grid
            Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
                SectionHeader("Training Modes")
                LazyVerticalGrid(
                    columns = GridCells.Fixed(2),
                    modifier = Modifier.height(490.dp),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp),
                    userScrollEnabled = false,
                ) {
                    items(TrainingModeCatalog.all) { mode ->
                        ModeTile(mode) { onLaunch(mode, "Unlock every training mode and your custom plan") }
                    }
                }
            }
        }
    }
}

@Composable
fun TodaysPlanCard(mode: TrainingMode, onClick: () -> Unit) {
    PressableCard(onClick = onClick) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clip(KT.shapeL)
                .background(Brush.linearGradient(listOf(mode.tint.copy(alpha = 0.18f), KT.surface)))
                .border(1.dp, mode.tint.copy(alpha = 0.4f), KT.shapeL)
                .padding(18.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(14.dp)) {
                Box(Modifier.size(52.dp).clip(RoundedCornerShape(14.dp)).background(mode.tint.copy(alpha = 0.15f)), contentAlignment = Alignment.Center) {
                    Icon(mode.icon, contentDescription = null, tint = mode.tint, modifier = Modifier.size(26.dp))
                }
                Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(mode.title, color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                    Text(mode.tagline, color = KT.textSecondary, fontSize = 12.sp)
                }
            }
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("${mode.defaultReps} moves", color = KT.textSecondary, fontWeight = FontWeight.SemiBold, fontSize = 12.sp)
                Spacer(Modifier.weight(1f))
                Icon(Icons.Filled.Schedule, contentDescription = null, tint = KT.textSecondary, modifier = Modifier.size(14.dp))
                Spacer(Modifier.size(4.dp))
                Text("~8 min", color = KT.textSecondary, fontWeight = FontWeight.SemiBold, fontSize = 12.sp)
                Spacer(Modifier.weight(1f))
                Icon(Icons.Filled.PlayCircle, contentDescription = null, tint = mode.tint, modifier = Modifier.size(26.dp))
            }
        }
    }
}

@Composable
fun ModeTile(mode: TrainingMode, onClick: () -> Unit) {
    PressableCard(onClick = onClick, modifier = Modifier.height(150.dp)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .clip(KT.shapeL)
                .background(KT.surface)
                .border(1.dp, KT.stroke, KT.shapeL)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Box(Modifier.size(46.dp).clip(RoundedCornerShape(12.dp)).background(mode.tint.copy(alpha = 0.15f)), contentAlignment = Alignment.Center) {
                Icon(mode.icon, contentDescription = null, tint = mode.tint, modifier = Modifier.size(24.dp))
            }
            Column(verticalArrangement = Arrangement.spacedBy(3.dp)) {
                Text(mode.title, color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                Text(mode.tagline, color = KT.textSecondary, fontSize = 11.sp, maxLines = 2)
            }
        }
    }
}

private fun greetingText(): String {
    val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
    return when (hour) {
        in 5..11 -> "Good morning"
        in 12..16 -> "Good afternoon"
        else -> "Good evening"
    }
}
