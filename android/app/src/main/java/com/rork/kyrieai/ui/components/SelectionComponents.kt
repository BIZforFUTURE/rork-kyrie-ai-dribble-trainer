package com.rork.kyrieai.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.ui.draw.clip
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rork.kyrieai.ui.theme.KT
import com.rork.kyrieai.util.Haptics

@Composable
fun SelectRow(
    title: String,
    isSelected: Boolean,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    icon: ImageVector? = null,
    tint: Color = KT.primary,
    onClick: () -> Unit,
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .clip(KT.shapeM)
            .background(if (isSelected) tint.copy(alpha = 0.12f) else KT.surface)
            .border(if (isSelected) 1.5.dp else 1.dp, if (isSelected) tint.copy(alpha = 0.6f) else KT.stroke, KT.shapeM)
            .clickable { Haptics.select(); onClick() }
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(14.dp),
    ) {
        if (icon != null) {
            Icon(icon, contentDescription = null, tint = if (isSelected) tint else KT.textSecondary, modifier = Modifier.size(26.dp))
        }
        Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(3.dp)) {
            Text(title, color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 17.sp)
            if (subtitle != null) Text(subtitle, color = KT.textSecondary, fontSize = 12.sp)
        }
        Box(contentAlignment = Alignment.Center) {
            Box(
                Modifier
                    .size(24.dp)
                    .clip(CircleShape)
                    .border(2.dp, if (isSelected) tint else KT.textTertiary, CircleShape)
            )
            if (isSelected) {
                Box(Modifier.size(14.dp).clip(CircleShape).background(tint))
            }
        }
    }
}

@Composable
fun DayToggle(
    short: String,
    label: String,
    isSelected: Boolean,
    modifier: Modifier = Modifier,
    onClick: () -> Unit,
) {
    Column(
        modifier = modifier
            .clip(KT.shapeM)
            .background(if (isSelected) KT.energyGradient else Brush.linearGradient(listOf(KT.surface, KT.surface)))
            .border(if (isSelected) 0.dp else 1.5.dp, if (isSelected) Color.Transparent else KT.stroke, KT.shapeM)
            .clickable { Haptics.select(); onClick() }
            .padding(vertical = 16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(6.dp),
    ) {
        Text(short, color = if (isSelected) KT.onAccent else KT.textPrimary, fontWeight = FontWeight.Black, fontSize = 18.sp)
        Text(
            label.take(3).uppercase(),
            color = if (isSelected) KT.onAccent.copy(alpha = 0.7f) else KT.textSecondary,
            fontWeight = FontWeight.Bold,
            fontSize = 10.sp,
        )
    }
}

@Composable
fun ChoiceChip(
    title: String,
    isSelected: Boolean,
    modifier: Modifier = Modifier,
    icon: ImageVector? = null,
    onClick: () -> Unit,
) {
    Row(
        modifier = modifier
            .clip(CircleShape)
            .background(if (isSelected) KT.primary else KT.surface)
            .border(if (isSelected) 0.dp else 1.5.dp, if (isSelected) Color.Transparent else KT.stroke, CircleShape)
            .clickable { Haptics.select(); onClick() }
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        if (icon != null) Icon(icon, contentDescription = null, tint = if (isSelected) KT.onAccent else KT.textPrimary, modifier = Modifier.size(18.dp))
        Text(title, color = if (isSelected) KT.onAccent else KT.textPrimary, fontWeight = FontWeight.SemiBold, fontSize = 14.sp)
    }
}
