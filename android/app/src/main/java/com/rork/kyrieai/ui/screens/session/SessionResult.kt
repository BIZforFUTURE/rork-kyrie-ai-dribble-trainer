package com.rork.kyrieai.ui.screens.session

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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.CenterFocusStrong
import androidx.compose.material.icons.filled.FormatQuote
import androidx.compose.material.icons.filled.SportsBasketball
import androidx.compose.material.icons.filled.Timer
import androidx.compose.material.icons.filled.Verified
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rork.kyrieai.data.TrainingMode
import com.rork.kyrieai.ui.components.ArenaBackground
import com.rork.kyrieai.ui.components.GlassCard
import com.rork.kyrieai.ui.components.PrimaryButton
import com.rork.kyrieai.ui.components.StatChip
import com.rork.kyrieai.ui.screens.onboarding.systemPadding
import com.rork.kyrieai.ui.theme.KT

@Composable
fun SessionResult(
    mode: TrainingMode,
    accuracy: Int,
    reactionMs: Int,
    moves: Int,
    xp: Int,
    onDone: () -> Unit,
) {
    val coachLine = when {
        accuracy >= 90 -> "Filthy handles. That was elite-level execution — keep this in your bag."
        accuracy >= 78 -> "Smooth and controlled. You're locking these moves in. Push the pace next time."
        accuracy >= 65 -> "Solid work. Tighten your control on the combos and you'll level up fast."
        else -> "Good reps. Slow it down, stay low, and focus on clean contact with the ball."
    }
    Box(Modifier.fillMaxSize().background(KT.background)) {
        ArenaBackground()
        Column(
            modifier = Modifier.fillMaxSize().systemPadding().verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(24.dp),
        ) {
            Spacer(Modifier.height(40.dp))
            Icon(Icons.Filled.Verified, contentDescription = null, tint = mode.tint, modifier = Modifier.size(70.dp))
            Text("Session Complete", color = KT.textPrimary, fontWeight = FontWeight.Black, fontSize = 28.sp)
            Text(mode.title, color = KT.textSecondary, fontWeight = FontWeight.SemiBold, fontSize = 14.sp)

            Row(
                modifier = Modifier.clip(CircleShape).background(KT.energy.copy(alpha = 0.14f)).border(1.dp, KT.energy.copy(alpha = 0.5f), CircleShape).padding(horizontal = 20.dp, vertical = 14.dp),
                verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                Icon(Icons.Filled.Bolt, contentDescription = null, tint = KT.energy, modifier = Modifier.size(20.dp))
                Text("+$xp XP earned", color = KT.textPrimary, fontWeight = FontWeight.Black, fontSize = 16.sp)
            }

            Row(Modifier.fillMaxWidth().padding(horizontal = 20.dp), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                StatChip("$accuracy%", "Execution", Modifier.weight(1f), mode.tint, Icons.Filled.CenterFocusStrong)
                StatChip("${reactionMs}ms", "Avg reaction", Modifier.weight(1f), KT.info, Icons.Filled.Timer)
                StatChip("$moves", "Moves", Modifier.weight(1f), KT.energy, Icons.Filled.SportsBasketball)
            }

            GlassCard(Modifier.fillMaxWidth().padding(horizontal = 20.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    Icon(Icons.Filled.FormatQuote, contentDescription = null, tint = KT.primary, modifier = Modifier.size(20.dp))
                    Text("Coach Kyrie AI", color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                }
                Spacer(Modifier.height(8.dp))
                Text(coachLine, color = KT.textSecondary, fontSize = 14.sp)
            }

            PrimaryButton("Done", icon = Icons.Filled.Check, modifier = Modifier.padding(horizontal = 20.dp), onClick = onDone)
            Spacer(Modifier.height(30.dp))
        }
    }
}
