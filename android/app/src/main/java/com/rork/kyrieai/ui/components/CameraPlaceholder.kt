package com.rork.kyrieai.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.PhotoCamera
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rork.kyrieai.ui.theme.KT

/**
 * Stand-in for the live camera feed. The cloud emulator has no physical camera,
 * so we show a clean placeholder. Overlay content sits on top.
 */
@Composable
fun CameraPlaceholder(
    modifier: Modifier = Modifier,
    overlay: @Composable () -> Unit = {},
) {
    Box(modifier = modifier) {
        Box(
            Modifier
                .fillMaxSize()
                .background(Brush.verticalGradient(listOf(Color(0xFF16161E), Color(0xFF0C0C12))))
        ) {
            Canvas(Modifier.fillMaxSize()) {
                val step = 44.dp.toPx()
                var x = 0f
                while (x < size.width) {
                    drawLine(Color.White.copy(alpha = 0.04f), Offset(x, 0f), Offset(x, size.height))
                    x += step
                }
                var y = 0f
                while (y < size.height) {
                    drawLine(Color.White.copy(alpha = 0.04f), Offset(0f, y), Offset(size.width, y))
                    y += step
                }
            }
            Column(
                modifier = Modifier.fillMaxSize().padding(bottom = 60.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = androidx.compose.foundation.layout.Arrangement.Center,
            ) {
                Icon(Icons.Filled.PhotoCamera, contentDescription = null, tint = KT.textSecondary, modifier = Modifier.size(34.dp))
                Text("Camera preview", color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 15.sp, modifier = Modifier.padding(top = 12.dp))
                Text(
                    "Install this app on your device via the Rork App to use the camera.",
                    color = KT.textTertiary, fontSize = 12.sp, textAlign = TextAlign.Center,
                    modifier = Modifier.padding(horizontal = 30.dp, vertical = 6.dp),
                )
            }
        }
        overlay()
    }
}
