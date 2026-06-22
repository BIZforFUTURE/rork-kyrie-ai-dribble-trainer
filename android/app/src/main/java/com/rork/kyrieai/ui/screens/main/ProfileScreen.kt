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
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.CenterFocusStrong
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.EmojiEvents
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.PanTool
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.Straighten
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.WorkspacePremium
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rork.kyrieai.data.KyrieViewModel
import com.rork.kyrieai.data.PlayerProfile
import com.rork.kyrieai.ui.components.ArenaBackground
import com.rork.kyrieai.ui.components.GlassCard
import com.rork.kyrieai.ui.components.PrimaryButton
import com.rork.kyrieai.ui.components.StatChip
import com.rork.kyrieai.ui.components.TagPill
import com.rork.kyrieai.ui.screens.onboarding.systemPadding
import com.rork.kyrieai.ui.theme.KT
import com.rork.kyrieai.util.Haptics

@Composable
fun ProfileScreen(
    vm: KyrieViewModel,
    profile: PlayerProfile,
    isPremium: Boolean,
    onUpgrade: () -> Unit,
) {
    var showReset by remember { mutableStateOf(false) }
    var showEdit by remember { mutableStateOf(false) }

    Box(Modifier.fillMaxSize()) {
        ArenaBackground()
        Column(
            modifier = Modifier
                .fillMaxSize().systemPadding().verticalScroll(rememberScrollState())
                .padding(horizontal = 18.dp).padding(top = 8.dp, bottom = 30.dp),
            verticalArrangement = Arrangement.spacedBy(22.dp),
        ) {
            // header
            GlassCard(Modifier.fillMaxWidth(), padding = 22) {
                Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(14.dp)) {
                    Box(Modifier.size(96.dp).clip(CircleShape).background(KT.fireGradient), contentAlignment = Alignment.Center) {
                        Text(initials(profile.name), color = KT.onAccent, fontWeight = FontWeight.Black, fontSize = 36.sp)
                    }
                    Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        Text(profile.name.ifEmpty { "Hooper" }, color = KT.textPrimary, fontWeight = FontWeight.Black, fontSize = 22.sp)
                        Text("${profile.position.label} · ${profile.skillLevel.label}", color = KT.textSecondary, fontSize = 14.sp)
                    }
                    Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                        TagPill(profile.tier.uppercase(), KT.primary, filled = true)
                        TagPill("${profile.dominantHand.label} HANDED", KT.info)
                    }
                }
            }

            // subscription
            GlassCard(Modifier.fillMaxWidth()) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    Box(Modifier.size(44.dp).clip(CircleShape).background(KT.fireGradient), contentAlignment = Alignment.Center) {
                        Icon(if (isPremium) Icons.Filled.WorkspacePremium else Icons.Filled.Bolt, contentDescription = null, tint = KT.onAccent, modifier = Modifier.size(22.dp))
                    }
                    Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(3.dp)) {
                        Text(if (isPremium) "Kyrie AI Pro" else "Go Pro", color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                        Text(
                            if (isPremium) "You're a Pro member — train without limits." else "Unlock assessments, workouts & coaching.",
                            color = KT.textSecondary, fontSize = 12.sp,
                        )
                    }
                    if (isPremium) TagPill("ACTIVE", KT.energy, filled = true)
                }
                if (!isPremium) {
                    Spacer(Modifier.height(14.dp))
                    PrimaryButton("Upgrade to Pro", icon = Icons.Filled.AutoAwesome, onClick = onUpgrade)
                }
            }

            // stats
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text("Your Stats", color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                    Spacer(Modifier.weight(1f))
                    Row(
                        modifier = Modifier.clip(CircleShape).background(KT.primary.copy(alpha = 0.12f)).clickable { Haptics.light(); showEdit = true }.padding(horizontal = 12.dp, vertical = 7.dp),
                        verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(5.dp),
                    ) {
                        Icon(Icons.Filled.Edit, contentDescription = null, tint = KT.primary, modifier = Modifier.size(14.dp))
                        Text("Edit", color = KT.primary, fontWeight = FontWeight.SemiBold, fontSize = 14.sp)
                    }
                }
                Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    StatChip("${profile.ballHandlerScore}", "Ball Handler Score", Modifier.weight(1f), KT.primary, Icons.Filled.Star)
                    StatChip(profile.heightFormatted, "Height", Modifier.weight(1f), KT.info, Icons.Filled.Straighten)
                }
                Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    StatChip("${profile.age}", "Age", Modifier.weight(1f), KT.energy, Icons.Filled.Person)
                    StatChip("${profile.longestStreak}d", "Best streak", Modifier.weight(1f), KT.gold, Icons.Filled.LocalFireDepartment)
                }
            }

            // goals
            GlassCard(Modifier.fillMaxWidth()) {
                Text("Training Goals", color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                Spacer(Modifier.height(12.dp))
                if (profile.goals.isEmpty()) {
                    Text("No goals set.", color = KT.textSecondary, fontSize = 14.sp)
                } else {
                    LazyVerticalGrid(
                        columns = GridCells.Adaptive(130.dp),
                        modifier = Modifier.height((((profile.goals.size + 1) / 2) * 44).dp),
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp),
                        userScrollEnabled = false,
                    ) {
                        items(profile.goals) { goal ->
                            Row(
                                modifier = Modifier.clip(CircleShape).background(KT.energy.copy(alpha = 0.12f)).padding(horizontal = 12.dp, vertical = 8.dp),
                                verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp),
                            ) {
                                Icon(goal.icon, contentDescription = null, tint = KT.energy, modifier = Modifier.size(13.dp))
                                Text(goal.label, color = KT.energy, fontWeight = FontWeight.SemiBold, fontSize = 12.sp, maxLines = 1)
                            }
                        }
                    }
                }
                Spacer(Modifier.height(14.dp))
                Box(Modifier.fillMaxWidth().height(1.dp).background(KT.stroke))
                Spacer(Modifier.height(14.dp))
                Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                    Text("Schedule", color = KT.textSecondary, fontSize = 14.sp)
                    Spacer(Modifier.weight(1f))
                    Text(profile.availability.label, color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                }
            }

            // achievements
            GlassCard(Modifier.fillMaxWidth()) {
                Text("Achievements", color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                Spacer(Modifier.height(14.dp))
                val badges = listOf(
                    Badge(Icons.Filled.LocalFireDepartment, "First Streak", profile.currentStreak >= 1, KT.primary),
                    Badge(Icons.Filled.Bolt, "1K XP", profile.totalXP >= 1000, KT.energy),
                    Badge(Icons.Filled.CenterFocusStrong, "Sharp", profile.controlScore >= 70, KT.info),
                    Badge(Icons.Filled.PanTool, "Ambidextrous", profile.weakHandScore >= 70, KT.energy),
                    Badge(Icons.Filled.EmojiEvents, "10 Sessions", profile.sessions.size >= 10, KT.gold),
                    Badge(Icons.Filled.WorkspacePremium, "Elite", profile.ballHandlerScore >= 85, KT.purple),
                )
                LazyVerticalGrid(
                    columns = GridCells.Fixed(3),
                    modifier = Modifier.height(180.dp),
                    horizontalArrangement = Arrangement.spacedBy(14.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp),
                    userScrollEnabled = false,
                ) {
                    items(badges) { b -> BadgeView(b) }
                }
            }

            // reset
            Text(
                "Reset Progress",
                color = KT.danger, fontWeight = FontWeight.SemiBold, fontSize = 14.sp, textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth().clip(KT.shapeM).background(KT.danger.copy(alpha = 0.1f)).clickable { showReset = true }.padding(vertical = 16.dp),
            )
        }
    }

    if (showReset) {
        AlertDialog(
            onDismissRequest = { showReset = false },
            title = { Text("Reset all progress?") },
            text = { Text("This deletes your profile, score, and session history.") },
            confirmButton = { TextButton(onClick = { showReset = false; vm.reset() }) { Text("Reset everything", color = KT.danger) } },
            dismissButton = { TextButton(onClick = { showReset = false }) { Text("Cancel") } },
            containerColor = KT.surfaceElevated,
        )
    }

    if (showEdit) {
        EditStatsDialog(profile, onSave = { age, h -> vm.updateStats(age, h); showEdit = false }, onDismiss = { showEdit = false })
    }
}

private data class Badge(val icon: ImageVector, val title: String, val unlocked: Boolean, val tint: Color)

@Composable
private fun BadgeView(b: Badge) {
    Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Box(
            Modifier.size(56.dp).clip(CircleShape).background((if (b.unlocked) b.tint else KT.textTertiary).copy(alpha = 0.14f)),
            contentAlignment = Alignment.Center,
        ) { Icon(b.icon, contentDescription = null, tint = if (b.unlocked) b.tint else KT.textTertiary, modifier = Modifier.size(24.dp)) }
        Text(b.title, color = if (b.unlocked) KT.textPrimary else KT.textTertiary, fontWeight = FontWeight.SemiBold, fontSize = 11.sp, textAlign = TextAlign.Center)
    }
}

@Composable
private fun EditStatsDialog(profile: PlayerProfile, onSave: (Int, Int) -> Unit, onDismiss: () -> Unit) {
    var age by remember { mutableIntStateOf(profile.age) }
    var height by remember { mutableIntStateOf(profile.heightInches) }
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Edit Stats") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
                Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                    Text("Age", color = KT.textPrimary, fontWeight = FontWeight.Bold)
                    Spacer(Modifier.weight(1f))
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                        Text("−", color = KT.primary, fontSize = 22.sp, fontWeight = FontWeight.Black, modifier = Modifier.clickable { age = (age - 1).coerceAtLeast(8) })
                        Text("$age", color = KT.primary, fontWeight = FontWeight.Black, fontSize = 20.sp)
                        Text("+", color = KT.primary, fontSize = 22.sp, fontWeight = FontWeight.Black, modifier = Modifier.clickable { age = (age + 1).coerceAtMost(60) })
                    }
                }
                Column {
                    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                        Text("Height", color = KT.textPrimary, fontWeight = FontWeight.Bold)
                        Spacer(Modifier.weight(1f))
                        Text("${height / 12}'${height % 12}\"", color = KT.primary, fontWeight = FontWeight.Bold)
                    }
                    Slider(
                        value = height.toFloat(),
                        onValueChange = { height = it.toInt() },
                        valueRange = 48f..84f,
                        colors = SliderDefaults.colors(thumbColor = KT.primary, activeTrackColor = KT.primary),
                    )
                }
            }
        },
        confirmButton = { TextButton(onClick = { Haptics.success(); onSave(age, height) }) { Text("Save", fontWeight = FontWeight.Bold) } },
        dismissButton = { TextButton(onClick = onDismiss) { Text("Cancel") } },
        containerColor = KT.surfaceElevated,
    )
}

private fun initials(name: String): String {
    val parts = name.split(" ").filter { it.isNotEmpty() }
    return when {
        parts.isEmpty() -> "K"
        parts.size == 1 -> parts[0].first().toString()
        else -> "${parts[0].first()}${parts[1].first()}"
    }
}
