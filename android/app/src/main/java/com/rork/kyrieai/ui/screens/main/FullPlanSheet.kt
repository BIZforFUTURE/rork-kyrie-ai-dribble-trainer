package com.rork.kyrieai.ui.screens.main

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.rork.kyrieai.data.PlayerProfile
import com.rork.kyrieai.data.TrainingModeCatalog
import com.rork.kyrieai.data.Weekday
import com.rork.kyrieai.ui.components.ArenaBackground
import com.rork.kyrieai.ui.components.GlassCard
import com.rork.kyrieai.ui.components.TagPill
import com.rork.kyrieai.ui.screens.onboarding.systemPadding
import com.rork.kyrieai.ui.theme.KT
import com.rork.kyrieai.util.Haptics
import java.util.Calendar

@Composable
fun FullPlanSheet(profile: PlayerProfile, onDismiss: () -> Unit) {
    Dialog(onDismissRequest = onDismiss, properties = DialogProperties(usePlatformDefaultWidth = false)) {
        Box(Modifier.fillMaxSize().background(KT.background)) {
            ArenaBackground()
            Column(Modifier.fillMaxSize().systemPadding()) {
                Row(
                    Modifier.fillMaxWidth().padding(horizontal = 18.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Text("Your Plan", color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 18.sp)
                    Spacer(Modifier.weight(1f))
                    Icon(
                        Icons.Filled.Close, contentDescription = "Close", tint = KT.textSecondary,
                        modifier = Modifier.size(26.dp).clickable { Haptics.light(); onDismiss() },
                    )
                }
                Column(
                    Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(horizontal = 18.dp).padding(bottom = 30.dp),
                ) {
                    GlassCard(Modifier.fillMaxWidth()) {
                        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            Icon(Icons.Filled.CalendarMonth, contentDescription = null, tint = KT.info, modifier = Modifier.size(20.dp))
                            Text("This Week", color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                        }
                        Spacer(Modifier.size(8.dp))
                        Text("${profile.trainingDays.size} days / week · ${profile.availability.subtitle}", color = KT.textSecondary, fontSize = 12.sp)
                        Spacer(Modifier.size(10.dp))
                        if (profile.orderedTrainingDays.isEmpty()) {
                            Text("No training days selected yet. Retake the quiz to set your schedule.", color = KT.textTertiary, fontSize = 12.sp)
                        } else {
                            val todayWeekday = todayWeekday()
                            profile.orderedTrainingDays.forEach { day ->
                                val isToday = day == todayWeekday
                                val mode = TrainingModeCatalog.mode(Calendar.getInstance().get(Calendar.DAY_OF_YEAR), profile.weakestCategories)
                                Spacer(Modifier.size(10.dp))
                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                                    Box(
                                        Modifier.size(42.dp).clip(RoundedCornerShape(11.dp)).background(if (isToday) KT.info else KT.surfaceElevated),
                                        contentAlignment = Alignment.Center,
                                    ) { Text(day.short.uppercase(), color = if (isToday) KT.onAccent else KT.textSecondary, fontWeight = FontWeight.Black, fontSize = 10.sp) }
                                    Box(Modifier.size(32.dp).clip(RoundedCornerShape(9.dp)).background(mode.tint.copy(alpha = 0.15f)), contentAlignment = Alignment.Center) {
                                        Icon(mode.icon, contentDescription = null, tint = mode.tint, modifier = Modifier.size(16.dp))
                                    }
                                    Column(Modifier.weight(1f)) {
                                        Text(mode.title, color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                                        Text("${mode.defaultReps} moves · ~8 min", color = KT.textSecondary, fontSize = 11.sp)
                                    }
                                    if (isToday) TagPill("TODAY", KT.info, filled = true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private fun todayWeekday(): Weekday {
    return when (Calendar.getInstance().get(Calendar.DAY_OF_WEEK)) {
        Calendar.MONDAY -> Weekday.MONDAY
        Calendar.TUESDAY -> Weekday.TUESDAY
        Calendar.WEDNESDAY -> Weekday.WEDNESDAY
        Calendar.THURSDAY -> Weekday.THURSDAY
        Calendar.FRIDAY -> Weekday.FRIDAY
        Calendar.SATURDAY -> Weekday.SATURDAY
        else -> Weekday.SUNDAY
    }
}
