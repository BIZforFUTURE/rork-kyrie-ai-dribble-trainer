package com.rork.kyrieai.ui.screens.main

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
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.automirrored.filled.ListAlt
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.TrackChanges
import androidx.compose.material.icons.filled.Tune
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rork.kyrieai.data.KyrieViewModel
import com.rork.kyrieai.data.PlayerProfile
import com.rork.kyrieai.data.TrainingMode
import com.rork.kyrieai.data.TrainingModeCatalog
import com.rork.kyrieai.ui.components.ArenaBackground
import com.rork.kyrieai.ui.components.GlassCard
import com.rork.kyrieai.ui.components.PressableCard
import com.rork.kyrieai.ui.components.SectionHeader
import com.rork.kyrieai.ui.components.TagPill
import com.rork.kyrieai.ui.screens.onboarding.systemPadding
import com.rork.kyrieai.ui.theme.KT
import com.rork.kyrieai.util.Haptics
import java.util.Calendar

@Composable
fun TrainScreen(
    vm: KyrieViewModel,
    profile: PlayerProfile,
    onLaunch: (TrainingMode, String) -> Unit,
) {
    var menuOpen by remember { mutableStateOf(false) }
    var showRetake by remember { mutableStateOf(false) }
    var showFullPlan by remember { mutableStateOf(false) }

    val recommended = TrainingModeCatalog.mode(
        Calendar.getInstance().get(Calendar.DAY_OF_YEAR),
        profile.weakestCategories,
    )

    Box(Modifier.fillMaxSize()) {
        ArenaBackground()
        Column(
            modifier = Modifier
                .fillMaxSize().systemPadding().verticalScroll(rememberScrollState())
                .padding(horizontal = 18.dp).padding(top = 8.dp, bottom = 30.dp),
            verticalArrangement = Arrangement.spacedBy(22.dp),
        ) {
            Row(verticalAlignment = Alignment.Top) {
                Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text("TRAIN", color = KT.primary, fontWeight = FontWeight.Black, fontSize = 12.sp, letterSpacing = 2.sp)
                    Text("Choose your work", color = KT.textPrimary, fontWeight = FontWeight.Black, fontSize = 28.sp)
                }
                Box {
                    Box(
                        Modifier.size(44.dp).clip(CircleShape).background(KT.surfaceElevated).border(1.dp, KT.stroke, CircleShape)
                            .clickable { Haptics.light(); menuOpen = true },
                        contentAlignment = Alignment.Center,
                    ) { Icon(Icons.Filled.Tune, contentDescription = "Options", tint = KT.textPrimary, modifier = Modifier.size(20.dp)) }
                    DropdownMenu(expanded = menuOpen, onDismissRequest = { menuOpen = false }) {
                        DropdownMenuItem(
                            text = { Text("View Full Plan") },
                            leadingIcon = { Icon(Icons.AutoMirrored.Filled.ListAlt, contentDescription = null) },
                            onClick = { menuOpen = false; showFullPlan = true },
                        )
                        DropdownMenuItem(
                            text = { Text("Retake Quiz") },
                            leadingIcon = { Icon(Icons.Filled.Refresh, contentDescription = null) },
                            onClick = { menuOpen = false; showRetake = true },
                        )
                    }
                }
            }

            Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
                SectionHeader("Today's Plan")
                TodaysPlanCard(recommended) { onLaunch(recommended, "Unlock every training mode and your custom plan") }
            }

            // plan focus
            GlassCard(Modifier.fillMaxWidth()) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    Icon(Icons.Filled.TrackChanges, contentDescription = null, tint = KT.energy, modifier = Modifier.size(20.dp))
                    Text("Your Plan Focus", color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                }
                Spacer(Modifier.size(8.dp))
                Text("Based on your assessment, Coach is pushing these areas:", color = KT.textSecondary, fontSize = 12.sp)
                Spacer(Modifier.size(10.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    profile.weakestCategories.forEach { cat ->
                        Row(
                            modifier = Modifier.clip(CircleShape).background(cat.color.copy(alpha = 0.14f)).padding(horizontal = 12.dp, vertical = 8.dp),
                            verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp),
                        ) {
                            Icon(cat.icon, contentDescription = null, tint = cat.color, modifier = Modifier.size(14.dp))
                            Text(cat.label, color = cat.color, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                        }
                    }
                }
            }

            SectionHeader("All Modes")
            Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
                TrainingModeCatalog.all.forEach { mode ->
                    val recommendedFlag = mode.focus.toSet().intersect(profile.weakestCategories.toSet()).isNotEmpty()
                    ModeRow(mode, recommendedFlag) { onLaunch(mode, "Unlock every training mode and your custom plan") }
                }
            }
        }
    }

    if (showRetake) {
        AlertDialog(
            onDismissRequest = { showRetake = false },
            title = { Text("Retake the welcome quiz?") },
            text = { Text("This restarts the welcome quiz and builds a fresh training plan. Your current profile will be cleared.") },
            confirmButton = { TextButton(onClick = { showRetake = false; Haptics.warning(); vm.reset() }) { Text("Retake Quiz", color = KT.danger) } },
            dismissButton = { TextButton(onClick = { showRetake = false }) { Text("Cancel") } },
            containerColor = KT.surfaceElevated,
        )
    }

    if (showFullPlan) {
        FullPlanSheet(profile) { showFullPlan = false }
    }
}

@Composable
fun ModeRow(mode: TrainingMode, recommended: Boolean, onClick: () -> Unit) {
    PressableCard(onClick = onClick) {
        Row(
            modifier = Modifier
                .fillMaxWidth().clip(KT.shapeL).background(KT.surface).border(1.dp, KT.stroke, KT.shapeL).padding(14.dp),
            verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            Box(Modifier.size(54.dp).clip(RoundedCornerShape(14.dp)).background(mode.tint.copy(alpha = 0.15f)), contentAlignment = Alignment.Center) {
                Icon(mode.icon, contentDescription = null, tint = mode.tint, modifier = Modifier.size(26.dp))
            }
            Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text(mode.title, color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                    if (recommended) TagPill("FOR YOU", KT.energy, filled = true)
                }
                Text(mode.tagline, color = KT.textSecondary, fontSize = 12.sp)
            }
            Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = null, tint = KT.textTertiary, modifier = Modifier.size(20.dp))
        }
    }
}
