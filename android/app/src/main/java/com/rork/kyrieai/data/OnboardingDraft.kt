package com.rork.kyrieai.data

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.runtime.mutableStateListOf

/** Mutable state collected across the onboarding steps. */
class OnboardingDraft {
    var name by mutableStateOf("")
    var age by mutableStateOf(16)
    var heightInches by mutableStateOf(70)
    var skillLevel by mutableStateOf<SkillLevel?>(null)
    var position by mutableStateOf<Position?>(null)
    var dominantHand by mutableStateOf<Hand?>(null)
    val goals = mutableStateListOf<TrainingGoal>()
    val trainingDays = mutableStateListOf<Weekday>()
    var specificRequests by mutableStateOf("")

    fun canContinue(step: OnboardingStep): Boolean = when (step) {
        OnboardingStep.WELCOME -> true
        OnboardingStep.NAME -> name.trim().isNotEmpty()
        OnboardingStep.PHYSICALS -> true
        OnboardingStep.SKILL -> skillLevel != null
        OnboardingStep.POSITION -> position != null
        OnboardingStep.HAND -> dominantHand != null
        OnboardingStep.GOALS -> goals.isNotEmpty()
        OnboardingStep.AVAILABILITY -> trainingDays.isNotEmpty()
        OnboardingStep.REQUESTS -> true
        OnboardingStep.READY -> true
        OnboardingStep.RATE -> true
    }
}

/** Order matches the iOS flow: welcome → details → ready → rate. */
enum class OnboardingStep {
    WELCOME, NAME, PHYSICALS, SKILL, POSITION, HAND, GOALS, AVAILABILITY, REQUESTS, READY, RATE;

    val progressIndex: Int get() = ordinal
}
