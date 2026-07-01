package com.rork.kyrieai.ui.screens.store

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
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
import androidx.compose.material.icons.automirrored.filled.ShowChart
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.CenterFocusWeak
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.GraphicEq
import androidx.compose.material.icons.filled.SportsBasketball
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rork.kyrieai.data.BillingManager
import com.rork.kyrieai.ui.components.ArenaBackground
import com.rork.kyrieai.ui.components.GlassCard
import com.rork.kyrieai.ui.components.PrimaryButton
import com.rork.kyrieai.ui.components.TagPill
import com.rork.kyrieai.ui.screens.onboarding.systemPadding
import com.rork.kyrieai.ui.theme.KT
import com.rork.kyrieai.util.Haptics

private data class Plan(val title: String, val productId: String, val price: String, val sub: String, val annual: Boolean)

@Composable
fun PaywallScreen(
    context: String,
    isPremium: Boolean,
    onPurchase: (productId: String) -> Unit,
    onRestore: () -> Unit,
    priceFor: (productId: String) -> String?,
    onClose: () -> Unit,
) {
    val plans = listOf(
        Plan("Yearly", BillingManager.YEARLY_ID, "$3.33", "3-day free trial, then $3.33/mo ($39.99/yr)", true),
        Plan("Monthly", BillingManager.MONTHLY_ID, "$9.99", "3-day free trial, then $9.99/mo", false),
    )
    var selected by remember { mutableStateOf(0) }

    val perks = listOf(
        Icons.Filled.CenterFocusWeak to "AI skill assessment & Ball Handler Score",
        Icons.Filled.SportsBasketball to "Unlimited daily workouts & training modes",
        Icons.Filled.GraphicEq to "Real-time voice coaching during sessions",
        Icons.AutoMirrored.Filled.ShowChart to "Progress tracking & personalized plans",
    )

    Box(Modifier.fillMaxSize().background(KT.background)) {
        ArenaBackground()
        Column(
            modifier = Modifier.fillMaxSize().systemPadding().verticalScroll(rememberScrollState())
                .padding(horizontal = 22.dp).padding(top = 40.dp, bottom = 30.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(26.dp),
        ) {
            // hero
            Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(16.dp)) {
                Box(contentAlignment = Alignment.Center) {
                    Box(Modifier.size(130.dp).blur(26.dp).clip(CircleShape).background(KT.primary.copy(alpha = 0.18f)))
                    Icon(Icons.Filled.SportsBasketball, contentDescription = null, tint = KT.primary, modifier = Modifier.size(60.dp))
                }
                Text("KYRIE AI PRO", color = KT.primary, fontWeight = FontWeight.Black, fontSize = 12.sp, letterSpacing = 3.sp)
                Text("Train Like a Pro", color = KT.textPrimary, fontWeight = FontWeight.Black, fontSize = 32.sp)
                Text(context, color = KT.textSecondary, fontSize = 14.sp, textAlign = TextAlign.Center)
            }

            // perks
            GlassCard(Modifier.fillMaxWidth()) {
                perks.forEachIndexed { i, perk ->
                    if (i > 0) Spacer(Modifier.height(14.dp))
                    PerkRow(perk.first, perk.second)
                }
            }

            // plans
            Column(Modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                plans.forEachIndexed { index, plan ->
                    PlanRow(plan, priceFor(plan.productId), selected == index) { Haptics.select(); selected = index }
                }
            }

            PrimaryButton("Start 3-Day Free Trial", icon = Icons.Filled.Bolt, onClick = { onPurchase(plans[selected].productId) })
            Text(
                "3 days free, then ${if (plans[selected].annual) "billed annually" else "billed monthly"}. Cancel anytime.",
                color = KT.textTertiary, fontSize = 11.sp, textAlign = TextAlign.Center,
            )
            Text(
                "Payment is charged to your Google Play account. Subscriptions auto-renew unless cancelled at least 24 hours before the end of the period.",
                color = KT.textTertiary, fontSize = 11.sp, textAlign = TextAlign.Center, modifier = Modifier.padding(horizontal = 8.dp),
            )
            Text(
                "Restore purchases",
                color = KT.textSecondary, fontSize = 13.sp, fontWeight = FontWeight.SemiBold,
                textAlign = TextAlign.Center,
                modifier = Modifier.clickable { Haptics.light(); onRestore() }.padding(8.dp),
            )
        }
        // close button
        Box(
            Modifier.align(Alignment.TopEnd).systemPadding().padding(top = 8.dp, end = 18.dp)
                .size(34.dp).clip(CircleShape).background(KT.surfaceElevated).clickable { Haptics.light(); onClose() },
            contentAlignment = Alignment.Center,
        ) { Icon(Icons.Filled.Close, contentDescription = "Close", tint = KT.textSecondary, modifier = Modifier.size(18.dp)) }
    }
}

@Composable
private fun PerkRow(icon: ImageVector, text: String) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(14.dp)) {
        Box(Modifier.size(34.dp).clip(CircleShape).background(KT.primary.copy(alpha = 0.14f)), contentAlignment = Alignment.Center) {
            Icon(icon, contentDescription = null, tint = KT.primary, modifier = Modifier.size(18.dp))
        }
        Text(text, color = KT.textPrimary, fontWeight = FontWeight.Medium, fontSize = 14.sp)
    }
}

@Composable
private fun PlanRow(plan: Plan, livePrice: String?, selected: Boolean, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth().clip(KT.shapeM).background(KT.surface)
            .border(if (selected) 2.dp else 1.dp, if (selected) KT.primary else KT.stroke, KT.shapeM)
            .clickable { onClick() }.padding(16.dp),
        verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(14.dp),
    ) {
        Box(Modifier.size(24.dp).clip(CircleShape).border(2.dp, if (selected) KT.primary else KT.stroke, CircleShape), contentAlignment = Alignment.Center) {
            if (selected) Box(Modifier.size(14.dp).clip(CircleShape).background(KT.primary))
        }
        Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(3.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(plan.title, color = KT.textPrimary, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                if (plan.annual) TagPill("BEST VALUE", KT.energy, filled = true)
                TagPill("3 DAYS FREE", KT.info)
            }
            Text(plan.sub, color = KT.energy, fontSize = 11.sp)
        }
        Column(horizontalAlignment = Alignment.End) {
            Text(livePrice ?: plan.price, color = KT.textPrimary, fontWeight = FontWeight.Black, fontSize = 18.sp)
            Text(if (plan.annual) "/yr" else "/mo", color = if (plan.annual) KT.energy else KT.textSecondary, fontWeight = FontWeight.Bold, fontSize = 10.sp)
        }
    }
}
