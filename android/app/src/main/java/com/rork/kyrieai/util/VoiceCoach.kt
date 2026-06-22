package com.rork.kyrieai.util

import android.content.Context
import android.speech.tts.TextToSpeech
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import java.util.Locale

/** On-device text-to-speech coach that calls out moves and reacts to reps. */
class VoiceCoach(context: Context) {
    var isEnabled by mutableStateOf(true)

    private var tts: TextToSpeech? = null
    private var ready = false

    init {
        tts = TextToSpeech(context.applicationContext) { status ->
            if (status == TextToSpeech.SUCCESS) {
                tts?.language = Locale.US
                ready = true
            }
        }
    }

    fun command(text: String, rate: Float = 0.95f) {
        if (!isEnabled || !ready) return
        tts?.setSpeechRate(rate)
        tts?.speak(text, TextToSpeech.QUEUE_ADD, null, text)
    }

    fun feedback(text: String) {
        if (!isEnabled || !ready) return
        tts?.setSpeechRate(1.0f)
        tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "fb")
    }

    fun stop() {
        tts?.stop()
    }

    fun shutdown() {
        tts?.stop()
        tts?.shutdown()
        tts = null
        ready = false
    }
}
