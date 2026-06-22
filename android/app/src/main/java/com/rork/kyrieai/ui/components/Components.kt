package com.rork.kyrieai.ui.components

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rork.kyrieai.ui.theme.KT
import com.rork.kyrieai.util.Haptics

@Composable
fun GlassCard(
    modifier: Modifier = Modifier,
    padding: Int = 18,
    content: @Composable () -> Unit,
) {
    Column(
        modifier = modifier
            .clip(KT.shapeL)
            .background(KT.surface)
            .border(1.dp, KT.stroke, KT.shapeL)
            .padding(padding.dp),
    ) { content() }
}

@Composable
fun PrimaryButton(
    title: String,
    modifier: Modifier = Modifier,
    icon: ImageVector? = null,
    gradient: Brush = KT.fireGradient,
    enabled: Boolean = true,
    onClick: () -> Unit,
) {
    val interaction = remember { MutableInteractionSource() }
    val pressed by interaction.collectIsPressedAsState()
    Row(
        modifier = modifier
            .fillMaxWidth()
            .scale(if (pressed) 0.97f else 1f)
            .alpha(if (enabled) 1f else 0.4f)
            .clip(KT.shapeM)
            .background(gradient)
            .border(1.dp, Color.White.copy(alpha = 0.25f), KT.shapeM)
            .clickable(interactionSource = interaction, indication = null, enabled = enabled) {
                Haptics.tap(); onClick()
            }
            .padding(vertical = 17.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (icon != null) {
            Icon(icon, contentDescription = null, tint = Color(0xFF140A04), modifier = Modifier.size(20.dp))
            Spacer(Modifier.size(10.dp))
        }
        Text(title, color = Color(0xFF140A04), fontWeight = FontWeight.Bold, fontSize = 17.sp)
    }
}

@Composable
fun GhostButton(
    title: String,
    modifier: Modifier = Modifier,
    icon: ImageVector? = null,
    onClick: () -> Unit,
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .clip(KT.shapeM)
            .background(KT.surfaceElevated)
            .border(1.dp, KT.stroke, KT.shapeM)
            .clickable { Haptics.light(); onClick() }
            .padding(vertical = 16.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (icon != null) {
            Icon(icon, contentDescription = null, tint = KT.textPrimary, modifier = Modifier.size(18.dp))
            Spacer(Modifier.size(8.dp))
        }
        Text(title, color = KT.textPrimary, fontWeight = FontWeight.SemiBold)
    }
}

@Composable
fun ScoreRing(
    progress: Float,
    modifier: Modifier = Modifier,
    size: Int = 180,
    lineWidth: Int = 16,
    content: @Composable () -> Unit,
) {
    val sweep = Brush.sweepGradient(listOf(KT.primary, KT.energy, KT.info, KT.primary))
    Box(modifier = modifier.size(size.dp), contentAlignment = Alignment.Center) {
        androidx.compose.foundation.Canvas(modifier = Modifier.fillMaxSize()) {
            val stroke = lineWidth.dp.toPx()
            val inset = stroke / 2
            drawArc(
                color = Color.White.copy(alpha = 0.07f),
                startAngle = 0f,
                sweepAngle = 360f,
                useCenter = false,
                topLeft = Offset(inset, inset),
                size = androidx.compose.ui.geometry.Size(this.size.width - stroke, this.size.height - stroke),
                style = Stroke(width = stroke),
            )
            drawArc(
                brush = sweep,
                startAngle = -90f,
                sweepAngle = 360f * progress.coerceIn(0f, 1f),
                useCenter = false,
                topLeft = Offset(inset, inset),
                size = androidx.compose.ui.geometry.Size(this.size.width - stroke, this.size.height - stroke),
                style = Stroke(width = stroke, cap = StrokeCap.Round),
            )
        }
        content()
    }
}

@Composable
fun TagPill(
    text: String,
    color: Color = KT.energy,
    filled: Boolean = false,
    modifier: Modifier = Modifier,
) {
    Text(
        text = text,
        color = if (filled) KT.onAccent else color,
        fontWeight = FontWeight.Bold,
        fontSize = 11.sp,
        modifier = modifier
            .clip(CircleShape)
            .background(if (filled) color else color.copy(alpha = 0.14f))
            .padding(horizontal = 11.dp, vertical = 6.dp),
    )
}

@Composable
fun SectionHeader(
    title: String,
    modifier: Modifier = Modifier,
) {
    Text(
        title,
        color = KT.textPrimary,
        fontWeight = FontWeight.Bold,
        fontSize = 20.sp,
        modifier = modifier,
    )
}

@Composable
fun StatChip(
    value: String,
    label: String,
    modifier: Modifier = Modifier,
    tint: Color = KT.primary,
    icon: ImageVector? = null,
) {
    Column(
        modifier = modifier
            .clip(KT.shapeM)
            .background(KT.surface)
            .border(1.dp, KT.stroke, KT.shapeM)
            .padding(14.dp),
        verticalArrangement = Arrangement.spacedBy(6.dp),
    ) {
        if (icon != null) {
            Icon(icon, contentDescription = null, tint = tint, modifier = Modifier.size(18.dp))
        }
        Text(value, color = KT.textPrimary, fontWeight = FontWeight.Black, fontSize = 22.sp)
        Text(label, color = KT.textSecondary, fontSize = 12.sp)
    }
}

/** Animated atmospheric background with glowing orbs. */
@Composable
fun ArenaBackground(modifier: Modifier = Modifier) {
    val transition = rememberInfiniteTransition(label = "arena")
    val shift by transition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(8000, easing = LinearEasing), RepeatMode.Reverse),
        label = "shift",
    )
    Box(
        modifier = modifier
            .fillMaxSize()
            .background(
                Brush.radialGradient(
                    colors = listOf(Color(0xFF1A1320), KT.background),
                    center = Offset(0.5f, 0f),
                    radius = 1600f,
                )
            )
    ) {
        Orb(KT.primary.copy(alpha = 0.22f), 360, x = -100 - shift * 30, y = -280 + shift * 40)
        Orb(KT.energy.copy(alpha = 0.12f), 320, x = 130 + shift * 30, y = 340 - shift * 40)
        Orb(KT.info.copy(alpha = 0.08f), 260, x = -150 + shift * 20, y = 220 - shift * 40)
    }
}

@Composable
private fun Orb(color: Color, sizeDp: Int, x: Float, y: Float) {
    Box(
        modifier = Modifier
            .padding(start = (160 + x).dp.coerceAtLeastZero(), top = (380 + y).dp.coerceAtLeastZero())
            .size(sizeDp.dp)
            .blur(90.dp)
            .clip(CircleShape)
            .background(color)
    )
}

private fun androidx.compose.ui.unit.Dp.coerceAtLeastZero() = if (value < 0) 0.dp else this

@Composable
fun PressableCard(
    modifier: Modifier = Modifier,
    shape: RoundedCornerShape = KT.shapeL,
    onClick: () -> Unit,
    content: @Composable () -> Unit,
) {
    val interaction = remember { MutableInteractionSource() }
    val pressed by interaction.collectIsPressedAsState()
    Box(
        modifier = modifier
            .scale(if (pressed) 0.98f else 1f)
            .clip(shape)
            .clickable(interactionSource = interaction, indication = null) { Haptics.tap(); onClick() }
    ) { content() }
}

@Composable
fun OutlinedSurface(
    modifier: Modifier = Modifier,
    fill: Color = KT.surface,
    border: BorderStroke = BorderStroke(1.dp, KT.stroke),
    shape: RoundedCornerShape = KT.shapeM,
    content: @Composable () -> Unit,
) {
    Box(
        modifier = modifier
            .clip(shape)
            .background(fill)
            .border(border, shape),
    ) { content() }
}
