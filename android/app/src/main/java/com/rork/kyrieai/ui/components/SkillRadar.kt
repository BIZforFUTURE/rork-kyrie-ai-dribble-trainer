package com.rork.kyrieai.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.sp
import com.rork.kyrieai.data.SkillCategory
import com.rork.kyrieai.ui.theme.KT
import kotlin.math.cos
import kotlin.math.sin

@Composable
fun SkillRadar(
    scores: Map<SkillCategory, Int>,
    modifier: Modifier = Modifier,
) {
    val categories = SkillCategory.entries
    var appeared by remember { mutableStateOf(false) }
    val progress by animateFloatAsState(
        targetValue = if (appeared) 1f else 0f,
        animationSpec = spring(dampingRatio = 0.7f, stiffness = 120f),
        label = "radar",
    )
    LaunchedEffect(Unit) { appeared = true }
    val measurer = rememberTextMeasurer()

    Box(modifier = modifier.fillMaxSize()) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val center = Offset(size.width / 2, size.height / 2)
            val radius = (minOf(size.width, size.height) / 2) - 56f

            fun point(r: Float, index: Int): Offset {
                val angle = (index.toFloat() / categories.size) * 2f * Math.PI.toFloat() - Math.PI.toFloat() / 2f
                return Offset(center.x + r * cos(angle), center.y + r * sin(angle))
            }

            // grid rings
            for (ring in 1..4) {
                val path = Path()
                for (i in categories.indices) {
                    val pt = point(radius * ring / 4f, i)
                    if (i == 0) path.moveTo(pt.x, pt.y) else path.lineTo(pt.x, pt.y)
                }
                path.close()
                drawPath(path, Color.White.copy(alpha = 0.08f), style = Stroke(width = 1f))
            }
            // spokes
            for (i in categories.indices) {
                drawLine(Color.White.copy(alpha = 0.08f), center, point(radius, i), strokeWidth = 1f)
            }
            // data shape
            val dataPath = Path()
            for (i in categories.indices) {
                val v = (scores[categories[i]] ?: 0) / 100f
                val pt = point(radius * v * progress, i)
                if (i == 0) dataPath.moveTo(pt.x, pt.y) else dataPath.lineTo(pt.x, pt.y)
            }
            dataPath.close()
            drawPath(dataPath, KT.primary.copy(alpha = 0.22f))
            drawPath(dataPath, KT.primary, style = Stroke(width = 6f))

            // vertices
            for (i in categories.indices) {
                val v = (scores[categories[i]] ?: 0) / 100f
                drawCircle(categories[i].color, radius = 8f, center = point(radius * v * progress, i))
            }

            // labels
            for (i in categories.indices) {
                val pt = point(radius + 34f, i)
                val layout = measurer.measure(
                    categories[i].label,
                    style = TextStyle(color = KT.textSecondary, fontSize = 11.sp),
                )
                drawText(layout, topLeft = Offset(pt.x - layout.size.width / 2, pt.y - layout.size.height / 2))
            }
        }
    }
}
