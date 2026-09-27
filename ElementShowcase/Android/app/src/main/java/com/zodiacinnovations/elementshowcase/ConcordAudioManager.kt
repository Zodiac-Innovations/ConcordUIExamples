package com.zodiacinnovations.elementshowcase

import android.content.Context
import android.media.MediaPlayer
import android.media.PlaybackParams
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.util.Base64
import java.io.File
import java.util.Locale

object ConcordAudioNative {
    external fun audioDidFinish(kind: String, result: String)
}

/** Native Android implementation backing ConcordUI sound playback and text-to-speech. */
object ConcordAudioManager {
    private lateinit var context: Context
    private var player: MediaPlayer? = null
    private var playerFile: File? = null
    private var speech: TextToSpeech? = null
    private var speechReady = false
    private var speechInitializationFinished = false
    private var pendingSpeechText: String? = null
    private var pendingSpeechSpeed: Float = 1.0f
    private const val speechId = "ConcordUI-Speech"

    @JvmStatic
    fun initialize(value: Context) {
        context = value.applicationContext
        ConcordNative
        speechInitializationFinished = false
        speechReady = false
        pendingSpeechText = null
        speech = TextToSpeech(context) { status ->
            speechInitializationFinished = true
            speechReady = status == TextToSpeech.SUCCESS
            if (speechReady) {
                speech?.language = Locale.getDefault()
                val pendingText = pendingSpeechText
                if (pendingText != null) {
                    val pendingSpeed = pendingSpeechSpeed
                    pendingSpeechText = null
                    if (!startSpeech(pendingText, pendingSpeed)) {
                        ConcordAudioNative.audioDidFinish("speech", "failed")
                    }
                }
            } else if (pendingSpeechText != null) {
                pendingSpeechText = null
                ConcordAudioNative.audioDidFinish("speech", "failed")
            }
        }.also { engine ->
            engine.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                override fun onStart(utteranceId: String?) = Unit
                override fun onDone(utteranceId: String?) {
                    if (utteranceId == speechId) ConcordAudioNative.audioDidFinish("speech", "finished")
                }
                @Deprecated("Deprecated in Java")
                override fun onError(utteranceId: String?) {
                    if (utteranceId == speechId) ConcordAudioNative.audioDidFinish("speech", "failed")
                }
                override fun onError(utteranceId: String?, errorCode: Int) {
                    if (utteranceId == speechId) ConcordAudioNative.audioDidFinish("speech", "failed")
                }
                override fun onStop(utteranceId: String?, interrupted: Boolean) = Unit
            })
        }
    }

    @JvmStatic fun canPlaySound(): Boolean = ::context.isInitialized

    // Capability is available as soon as the Android TTS service has been requested.
    // Readiness is asynchronous; speakText queues an early request until initialization
    // completes instead of hiding text-to-speech from a Presentation built at startup.
    @JvmStatic fun canSpeakText(): Boolean = ::context.isInitialized && speech != null

    @JvmStatic
    fun playSound(encoded: String, extension: String, speed: String): Boolean {
        if (!::context.isInitialized) return false
        return try {
            val bytes = Base64.decode(encoded, Base64.DEFAULT)
            val file = File.createTempFile("concord-audio-", ".${'$'}extension", context.cacheDir)
            file.writeBytes(bytes)
            val mediaPlayer = MediaPlayer()
            mediaPlayer.setDataSource(file.absolutePath)
            mediaPlayer.setOnCompletionListener {
                releasePlayer()
                ConcordAudioNative.audioDidFinish("sound", "finished")
            }
            mediaPlayer.setOnErrorListener { _, _, _ ->
                releasePlayer()
                ConcordAudioNative.audioDidFinish("sound", "failed")
                true
            }
            mediaPlayer.prepare()
            mediaPlayer.playbackParams = PlaybackParams().setSpeed(speed.toFloat())
            player = mediaPlayer
            playerFile = file
            mediaPlayer.start()
            true
        } catch (_: Throwable) {
            releasePlayer()
            false
        }
    }

    @JvmStatic
    fun cancelSound(): Boolean {
        if (player != null) {
            try { player?.stop() } catch (_: Throwable) {}
            releasePlayer()
            ConcordAudioNative.audioDidFinish("sound", "cancelled")
        }
        return true
    }

    @JvmStatic
    fun speakText(text: String, speed: String): Boolean {
        if (speech == null) return false
        val speechSpeed = speed.toFloatOrNull() ?: return false
        if (!speechReady) {
            if (speechInitializationFinished) return false
            pendingSpeechText = text
            pendingSpeechSpeed = speechSpeed
            return true
        }
        return startSpeech(text, speechSpeed)
    }

    @JvmStatic
    fun cancelSpeech(): Boolean {
        val hadPendingSpeech = pendingSpeechText != null
        pendingSpeechText = null
        speech?.stop()
        if (speechReady || hadPendingSpeech) {
            ConcordAudioNative.audioDidFinish("speech", "cancelled")
        }
        return true
    }

    private fun startSpeech(text: String, speed: Float): Boolean {
        val engine = speech ?: return false
        if (!speechReady) return false
        engine.setSpeechRate(speed)
        return engine.speak(text, TextToSpeech.QUEUE_FLUSH, null, speechId) == TextToSpeech.SUCCESS
    }

    private fun releasePlayer() {
        try { player?.release() } catch (_: Throwable) {}
        player = null
        playerFile?.delete()
        playerFile = null
    }
}