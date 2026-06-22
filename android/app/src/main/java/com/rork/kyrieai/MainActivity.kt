package com.rork.kyrieai

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.Modifier
import com.rork.kyrieai.ui.navigation.AppNavigation
import com.rork.kyrieai.ui.theme.AppTheme
import com.rork.kyrieai.ui.theme.KT
import com.rork.kyrieai.util.Haptics

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Haptics.init(applicationContext)
        enableEdgeToEdge()
        setContent {
            AppTheme {
                androidx.compose.foundation.layout.Box(Modifier.fillMaxSize().background(KT.background)) {
                    AppNavigation()
                }
            }
        }
    }
}
