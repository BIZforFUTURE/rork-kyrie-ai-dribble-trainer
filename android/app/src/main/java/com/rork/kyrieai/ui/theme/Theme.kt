package com.rork.kyrieai.ui.theme

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

/** App-wide design tokens for a premium dark athletic aesthetic. */
object KT {
    // Core palette
    val background = Color(0xFF0B0B0F)
    val surface = Color(0xFF15151C)
    val surfaceElevated = Color(0xFF1E1E28)
    val stroke = Color.White.copy(alpha = 0.08f)

    val primary = Color(0xFFFF6B2C) // basketball orange
    val primaryLight = Color(0xFFFF8A3D)
    val primaryDeep = Color(0xFFE34915)
    val energy = Color(0xFFB8FF2E) // electric lime
    val energyDeep = Color(0xFF6FE000)
    val info = Color(0xFF3DDCFF) // cool cyan
    val infoDeep = Color(0xFF2A8FFF)

    val textPrimary = Color.White
    val textSecondary = Color.White.copy(alpha = 0.62f)
    val textTertiary = Color.White.copy(alpha = 0.38f)

    val onAccent = Color(0xFF0B0B0F)
    val danger = Color(0xFFFF5C5C)

    // Accent colors used across categories/moves
    val gold = Color(0xFFFFC53D)
    val pink = Color(0xFFFF5C8A)
    val purple = Color(0xFFB06BFF)

    val fireGradient = Brush.linearGradient(listOf(primaryLight, primary, primaryDeep))
    val energyGradient = Brush.linearGradient(listOf(energy, energyDeep))
    val coolGradient = Brush.linearGradient(listOf(info, infoDeep))

    // Radii
    val radiusS = 12.dp
    val radiusM = 18.dp
    val radiusL = 26.dp

    val shapeS = RoundedCornerShape(radiusS)
    val shapeM = RoundedCornerShape(radiusM)
    val shapeL = RoundedCornerShape(radiusL)
}

private val KyrieColorScheme = darkColorScheme(
    primary = KT.primary,
    onPrimary = KT.onAccent,
    secondary = KT.energy,
    onSecondary = KT.onAccent,
    tertiary = KT.info,
    background = KT.background,
    onBackground = KT.textPrimary,
    surface = KT.surface,
    onSurface = KT.textPrimary,
    surfaceVariant = KT.surfaceElevated,
    error = KT.danger,
)

@Composable
fun AppTheme(
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = KyrieColorScheme,
        content = content
    )
}
