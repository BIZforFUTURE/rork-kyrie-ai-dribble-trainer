package com.rork.kyrieai.ui.screens.assessment

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.animateIntAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
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
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.FormatQuote
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rork.kyrieai.data.PlayerProfile
import com.rork.kyrieai.data.SkillCategory
import com.rork.kyrieai.ui.components.GlassCard
import com.rork.kyrieai.ui.components.PrimaryButton
import com.rork.kyrieai.ui.components.ScoreRing
import com.rork.kyrieai.ui.components.SkillRadar
import com.rork.kyrieai.ui.components.TagPill
import com.rork.kyrieai.ui.screens.onboarding.systemPadding
import com.rork.kyrieai.ui.theme.KT
import com.rork.kyrieai.util.Haptics

@Composable
fun AssessmentResult(
    profile: PlayerProfile,
    categories: Map<SkillCategory, Int>,
    score: Int,
    onContinue: () -> Unit,
) {
    var reveal by remember { mutableStateOf(false) }
    val animatedScore by animateIntAsState(if (reveal) score else 0, tween(1400), label = "score")
    val ring by animateFloatAsState(if (reveal) score / 100f else 0f, tween(1400), label = "ring")

    val weakest = SkillCategory.entries.sortedBy { categories[it] ?: 0 }.take(2)
    val tier = when {
        score < 50 -> "Rookie Handle"
        score < 65 -> "Rising Handle"
        score < 78 -> "Bucket Getter"
        score < 90 -> "Elite Handle"
        else -> "Untouchable"
    }

    LaunchedEffect(Unit) { reveal = true; Haptics.success() }

    Column(
        modifier = Modifier.fillMaxSize().systemPadding().verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(26.dp),
    ) {
        Spacer(Modifier.height(30.dp))
        Text("YOUR BALL HANDLER SCORE", color = KT.textSecondary, fontWeight = FontWeight.Black, fontSize = 12.sp, letterSpacing = 2.sp)
        ScoreRing(progress = ring, size = 240, lineWidth = 20) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text("$animatedScore", color = KT.textPrimary, fontWeight = FontWeight.Black, fontSize = 72.sp)
                Text(tier, color = KT.primary, fontWeight = FontWeight.Bold, fontSize = 14.sp)
            }
        }
        SkillRadar(categories, modifier = Modifier.fillMaxWidth().height(260.dp).padding(horizontal = 20.dp))

        Column(modifier = Modifier.fillMaxWidth().padding(horizontal = 20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            SkillCategory.entries.forEach { cat ->
                CategoryBar(cat, categories[cat] ?: 0, reveal)
            }
        }

        GlassCard(Modifier.fillMaxWidth().padding(horizontal = 20.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Icon(Icons.Filled.AutoAwesome, contentDescription = null, tint = KT.energy, modifier = Modifier.size(20.dp))
                Text("Your Custom Development Plan", color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 16.sp)
            }
            Spacer(Modifier.height(8.dp))
            Text("Coach built a plan around your weakest areas and goals:", color = KT.textSecondary, fontSize = 14.sp)
            weakest.forEach { cat ->
                Spacer(Modifier.height(12.dp))
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    Icon(cat.icon, contentDescription = null, tint = cat.color, modifier = Modifier.size(22.dp))
                    Text("Prioritize ${cat.label}", color = KT.textPrimary, fontWeight = FontWeight.SemiBold, fontSize = 14.sp)
                    Spacer(Modifier.weight(1f))
                    TagPill("FOCUS", cat.color, filled = true)
                }
            }
            val request = profile.specificRequests.trim()
            if (request.isNotEmpty()) {
                Spacer(Modifier.height(14.dp))
                Box(Modifier.fillMaxWidth().height(1.dp).background(KT.stroke))
                Spacer(Modifier.height(14.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    Icon(Icons.Filled.FormatQuote, contentDescription = null, tint = KT.energy, modifier = Modifier.size(22.dp))
                    Column {
                        Text("Your request", color = KT.textSecondary, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                        Text(request, color = KT.textPrimary, fontWeight = FontWeight.SemiBold, fontSize = 14.sp)
                    }
                }
            }
        }

        PrimaryButton("Enter the Lab", icon = Icons.AutoMirrored.Filled.ArrowForward, modifier = Modifier.padding(horizontal = 20.dp), onClick = onContinue)
        Spacer(Modifier.height(30.dp))
    }
}

@Composable
fun CategoryBar(category: SkillCategory, value: Int, reveal: Boolean) {
    val width by animateFloatAsState(if (reveal) value / 100f else 0f, tween(900), label = "bar")
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
        Text(category.label, color = KT.textPrimary, fontWeight = FontWeight.SemiBold, fontSize = 14.sp, modifier = Modifier.width(104.dp))
        Box(Modifier.weight(1f).height(8.dp).clip(CircleShape).background(Color.White.copy(alpha = 0.07f))) {
            Box(Modifier.fillMaxWidth(width).height(8.dp).clip(CircleShape).background(category.color))
        }
        Text("$value", color = KT.textPrimary, fontWeight = FontWeight.Black, fontSize = 14.sp, modifier = Modifier.width(30.dp))
    }
}
