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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.SportsBasketball
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rork.kyrieai.data.PlayerProfile
import com.rork.kyrieai.data.SessionRecord
import com.rork.kyrieai.data.SkillCategory
import com.rork.kyrieai.data.TrainingModeCatalog
import com.rork.kyrieai.ui.components.ArenaBackground
import com.rork.kyrieai.ui.components.GlassCard
import com.rork.kyrieai.ui.components.SectionHeader
import com.rork.kyrieai.ui.components.SkillRadar
import com.rork.kyrieai.ui.screens.assessment.CategoryBar
import com.rork.kyrieai.ui.screens.onboarding.systemPadding
import com.rork.kyrieai.ui.theme.KT
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@Composable
fun ProgressScreen(profile: PlayerProfile) {
    val sessions = profile.sessions.sortedByDescending { it.date }
    Box(Modifier.fillMaxSize()) {
        ArenaBackground()
        Column(
            modifier = Modifier
                .fillMaxSize().systemPadding().verticalScroll(rememberScrollState())
                .padding(horizontal = 18.dp).padding(top = 8.dp, bottom = 30.dp),
            verticalArrangement = Arrangement.spacedBy(22.dp),
        ) {
            SectionHeader("Skill Profile")
            GlassCard(Modifier.fillMaxWidth()) {
                SkillRadar(profile.categoryScores, modifier = Modifier.fillMaxWidth().height(280.dp))
            }
            SectionHeader("Skill Breakdown")
            GlassCard(Modifier.fillMaxWidth()) {
                SkillCategory.entries.forEachIndexed { i, cat ->
                    if (i > 0) Spacer(Modifier.height(10.dp))
                    CategoryBar(cat, profile.score(cat), reveal = true)
                }
            }
            SectionHeader("Recent Sessions")
            if (sessions.isEmpty()) {
                GlassCard(Modifier.fillMaxWidth()) {
                    Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        Icon(Icons.Filled.SportsBasketball, contentDescription = null, tint = KT.textTertiary, modifier = Modifier.size(34.dp))
                        Text("No sessions yet", color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                        Text("Complete a training session to start tracking your growth.", color = KT.textSecondary, fontSize = 12.sp, textAlign = TextAlign.Center)
                    }
                }
            } else {
                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    sessions.take(8).forEach { SessionRow(it) }
                }
            }
        }
    }
}

@Composable
private fun SessionRow(session: SessionRecord) {
    val mode = TrainingModeCatalog.mode(session.modeID)
    val tint = mode?.tint ?: KT.primary
    GlassCard(Modifier.fillMaxWidth(), padding = 14) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(14.dp)) {
            Box(Modifier.size(46.dp).clip(RoundedCornerShape(12.dp)).background(tint.copy(alpha = 0.15f)), contentAlignment = Alignment.Center) {
                Icon(mode?.icon ?: Icons.Filled.SportsBasketball, contentDescription = null, tint = tint, modifier = Modifier.size(22.dp))
            }
            Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(3.dp)) {
                Text(session.modeTitle, color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                Text(SimpleDateFormat("EEE, MMM d · h:mm a", Locale.getDefault()).format(Date(session.date)), color = KT.textSecondary, fontSize = 11.sp)
            }
            Column(horizontalAlignment = Alignment.End, verticalArrangement = Arrangement.spacedBy(3.dp)) {
                Text("${session.accuracy}%", color = tint, fontWeight = FontWeight.Black, fontSize = 14.sp)
                Text("+${session.xpEarned} XP", color = KT.energy, fontWeight = FontWeight.SemiBold, fontSize = 11.sp)
            }
        }
    }
}
