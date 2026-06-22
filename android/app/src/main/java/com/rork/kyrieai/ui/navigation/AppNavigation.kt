package com.rork.kyrieai.ui.navigation

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.rork.kyrieai.data.KyrieViewModel
import com.rork.kyrieai.ui.screens.assessment.AssessmentScreen
import com.rork.kyrieai.ui.screens.main.MainScreen
import com.rork.kyrieai.ui.screens.onboarding.OnboardingScreen
import com.rork.kyrieai.ui.theme.KT

private enum class Root { ONBOARDING, ASSESSMENT, MAIN }

@Composable
fun AppNavigation() {
    val vm: KyrieViewModel = viewModel()
    val profile by vm.profile.collectAsStateWithLifecycle()

    val root = when {
        profile == null || profile?.hasOnboarded != true -> Root.ONBOARDING
        profile?.hasAssessment != true -> Root.ASSESSMENT
        else -> Root.MAIN
    }

    Box(modifier = Modifier.fillMaxSize()) {
        AnimatedContent(
            targetState = root,
            transitionSpec = { fadeIn() togetherWith fadeOut() },
            label = "root",
        ) { target ->
            when (target) {
                Root.ONBOARDING -> OnboardingScreen(vm)
                Root.ASSESSMENT -> AssessmentScreen(vm)
                Root.MAIN -> MainScreen(vm)
            }
        }
    }
}
