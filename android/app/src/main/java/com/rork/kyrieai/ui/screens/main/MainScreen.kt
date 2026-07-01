package com.rork.kyrieai.ui.screens.main

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ShowChart
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.SportsBasketball
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.widget.Toast
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.rork.kyrieai.data.KyrieViewModel
import com.rork.kyrieai.data.TrainingMode
import com.rork.kyrieai.ui.screens.session.TrainingSessionScreen
import com.rork.kyrieai.ui.screens.store.PaywallScreen
import com.rork.kyrieai.ui.theme.KT
import com.rork.kyrieai.util.Haptics

private data class Tab(val label: String, val icon: ImageVector)

private fun Context.findActivity(): Activity? {
    var context: Context? = this
    while (context is ContextWrapper) {
        if (context is Activity) return context
        context = context.baseContext
    }
    return null
}

@Composable
fun MainScreen(vm: KyrieViewModel) {
    val profile by vm.profile.collectAsStateWithLifecycle()
    val isPremium by vm.isPremium.collectAsStateWithLifecycle()
    val billingStatus by vm.billingStatus.collectAsStateWithLifecycle()
    val p = profile ?: return

    val ctx = LocalContext.current
    val activity = remember(ctx) { ctx.findActivity() }

    var selected by remember { mutableIntStateOf(0) }
    var sessionMode by remember { mutableStateOf<TrainingMode?>(null) }
    var showPaywall by remember { mutableStateOf(false) }
    var paywallContext by remember { mutableStateOf("Unlock your full training experience") }

    // Auto-dismiss the paywall once Play confirms the entitlement.
    LaunchedEffect(isPremium) {
        if (isPremium) showPaywall = false
    }

    // Surface billing errors.
    LaunchedEffect(billingStatus) {
        billingStatus?.let {
            Toast.makeText(ctx, it, Toast.LENGTH_LONG).show()
            vm.clearBillingStatus()
        }
    }

    val tabs = listOf(
        Tab("Today", Icons.Filled.Home),
        Tab("Train", Icons.Filled.SportsBasketball),
        Tab("Progress", Icons.AutoMirrored.Filled.ShowChart),
        Tab("Profile", Icons.Filled.Person),
    )

    val launch: (TrainingMode, String) -> Unit = { mode, ctx ->
        if (isPremium) {
            sessionMode = mode
        } else {
            Haptics.warning()
            paywallContext = ctx
            showPaywall = true
        }
    }

    Box(Modifier.fillMaxSize().background(KT.background)) {
        Scaffold(
            containerColor = KT.background,
            bottomBar = {
                NavigationBar(containerColor = KT.background) {
                    tabs.forEachIndexed { index, tab ->
                        NavigationBarItem(
                            selected = selected == index,
                            onClick = { if (selected != index) Haptics.select(); selected = index },
                            icon = { Icon(tab.icon, contentDescription = tab.label) },
                            label = { Text(tab.label, fontWeight = FontWeight.SemiBold) },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = KT.primary,
                                selectedTextColor = KT.primary,
                                unselectedIconColor = KT.textTertiary,
                                unselectedTextColor = KT.textTertiary,
                                indicatorColor = KT.primary.copy(alpha = 0.12f),
                            ),
                        )
                    }
                }
            },
        ) { inner ->
            Box(Modifier.fillMaxSize().padding(bottom = inner.calculateBottomPadding())) {
                when (selected) {
                    0 -> HomeScreen(p, onLaunch = launch, onUpgrade = { showPaywall = true })
                    1 -> TrainScreen(vm, p, onLaunch = launch)
                    2 -> ProgressScreen(p)
                    else -> ProfileScreen(vm, p, isPremium, onUpgrade = { showPaywall = true })
                }
            }
        }

        AnimatedVisibility(
            visible = sessionMode != null,
            enter = slideInVertically { it } + fadeIn(),
            exit = slideOutVertically { it } + fadeOut(),
        ) {
            sessionMode?.let { mode ->
                TrainingSessionScreen(
                    mode = mode,
                    onFinish = { accuracy, reaction, xp, moves, duration ->
                        vm.recordSession(mode, accuracy, reaction, xp, moves, duration)
                        sessionMode = null
                    },
                    onClose = { sessionMode = null },
                )
            }
        }

        AnimatedVisibility(
            visible = showPaywall,
            enter = slideInVertically { it } + fadeIn(),
            exit = slideOutVertically { it } + fadeOut(),
        ) {
            PaywallScreen(
                context = paywallContext,
                isPremium = isPremium,
                onPurchase = { productId -> activity?.let { vm.purchase(it, productId) } },
                onRestore = { vm.restorePurchases() },
                priceFor = { productId -> vm.priceFor(productId) },
                onClose = { showPaywall = false },
            )
        }
    }
}
