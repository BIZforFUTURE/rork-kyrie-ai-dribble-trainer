package com.rork.kyrieai.ui.screens.onboarding

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.tween
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.statusBars
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowLeft
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.rork.kyrieai.data.KyrieViewModel
import com.rork.kyrieai.data.OnboardingDraft
import com.rork.kyrieai.data.OnboardingStep
import com.rork.kyrieai.ui.components.ArenaBackground
import com.rork.kyrieai.ui.components.PrimaryButton
import com.rork.kyrieai.ui.theme.KT
import com.rork.kyrieai.util.Haptics

@Composable
fun OnboardingScreen(vm: KyrieViewModel) {
    val draft = remember { OnboardingDraft() }
    var step by remember { mutableStateOf(OnboardingStep.WELCOME) }

    Box(modifier = Modifier.fillMaxSize().background(KT.background)) {
        ArenaBackground()
        Column(modifier = Modifier.fillMaxSize().systemPadding().imePadding()) {
            if (step != OnboardingStep.WELCOME) {
                ProgressBar(step, Modifier.padding(horizontal = 20.dp, vertical = 8.dp))
            }

            AnimatedContent(
                targetState = step,
                transitionSpec = {
                    if (targetState.ordinal > initialState.ordinal) {
                        (slideInHorizontally { it } + fadeIn()) togetherWith (slideOutHorizontally { -it } + fadeOut())
                    } else {
                        (slideInHorizontally { -it } + fadeIn()) togetherWith (slideOutHorizontally { it } + fadeOut())
                    }
                },
                modifier = Modifier.weight(1f),
                label = "step",
            ) { current ->
                when (current) {
                    OnboardingStep.WELCOME -> WelcomeStep()
                    OnboardingStep.NAME -> NameStep(draft)
                    OnboardingStep.PHYSICALS -> PhysicalsStep(draft)
                    OnboardingStep.SKILL -> SkillStep(draft)
                    OnboardingStep.POSITION -> PositionStep(draft)
                    OnboardingStep.HAND -> HandStep(draft)
                    OnboardingStep.GOALS -> GoalsStep(draft)
                    OnboardingStep.AVAILABILITY -> AvailabilityStep(draft)
                    OnboardingStep.REQUESTS -> RequestsStep(draft)
                    OnboardingStep.READY -> ReadyStep(draft)
                    OnboardingStep.RATE -> RateStep()
                }
            }

            Footer(
                step = step,
                canContinue = draft.canContinue(step),
                onBack = {
                    Haptics.light()
                    step = OnboardingStep.entries[(step.ordinal - 1).coerceAtLeast(0)]
                },
                onNext = {
                    if (step == OnboardingStep.RATE) {
                        Haptics.success()
                        vm.commitOnboarding(draft)
                    } else {
                        step = OnboardingStep.entries[step.ordinal + 1]
                    }
                },
                modifier = Modifier.padding(horizontal = 20.dp).padding(bottom = 12.dp),
            )
        }
    }
}

@Composable
private fun ProgressBar(step: OnboardingStep, modifier: Modifier = Modifier) {
    val total = (OnboardingStep.entries.size - 1).toFloat()
    val value = step.progressIndex / total
    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(6.dp)
            .clip(CircleShape)
            .background(KT.stroke),
    ) {
        Box(
            Modifier
                .fillMaxWidth(value)
                .height(6.dp)
                .clip(CircleShape)
                .background(KT.fireGradient)
        )
    }
}

@Composable
private fun Footer(
    step: OnboardingStep,
    canContinue: Boolean,
    onBack: () -> Unit,
    onNext: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Row(modifier = modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
        if (step != OnboardingStep.WELCOME) {
            Box(
                modifier = Modifier
                    .size(56.dp)
                    .clip(CircleShape)
                    .background(KT.surfaceElevated)
                    .border(1.dp, KT.stroke, CircleShape)
                    .clickable { onBack() },
                contentAlignment = Alignment.Center,
            ) {
                Icon(Icons.AutoMirrored.Filled.KeyboardArrowLeft, contentDescription = "Back", tint = KT.textPrimary)
            }
        }
        PrimaryButton(
            title = when (step) {
                OnboardingStep.RATE -> "Start Assessment"
                OnboardingStep.WELCOME -> "Let's Go"
                else -> "Continue"
            },
            enabled = canContinue,
            modifier = Modifier.weight(1f),
            onClick = onNext,
        )
    }
}

/** Adds top + bottom system bar padding. */
@Composable
fun Modifier.systemPadding(): Modifier {
    val top = WindowInsets.statusBars.asPaddingValues().calculateTopPadding()
    val bottom = WindowInsets.navigationBars.asPaddingValues().calculateBottomPadding()
    return this.then(Modifier.padding(top = top, bottom = bottom))
}
