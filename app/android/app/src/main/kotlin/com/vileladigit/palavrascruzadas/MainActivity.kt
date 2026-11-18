package com.vileladigit.palavrascruzadas

import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.SoundPool
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Sons e vibração seguindo o modo do celular, sem pedir nada à pessoa:
 * - modo Som: toca o som;
 * - modo Vibrar ou Silencioso: só vibra;
 * - Não perturbe ligado: nem som nem vibração.
 */
class MainActivity : FlutterActivity() {
    private var sons: SoundPool? = null
    private val ids = mutableMapOf<String, Int>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val pool = SoundPool.Builder()
            .setMaxStreams(2)
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_GAME)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
            .build()
        ids["vitoria"] = pool.load(this, R.raw.som_vitoria, 1)
        ids["recorde"] = pool.load(this, R.raw.som_recorde, 1)
        ids["conquista"] = pool.load(this, R.raw.som_conquista, 1)
        sons = pool

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "palavras_cruzadas/sons")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "tocar" -> {
                        val nome = call.argument<String>("som") ?: "vitoria"
                        result.success(tocar(nome))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /** Devolve o que fez: "som", "vibrou" ou "nada". */
    private fun tocar(nome: String): String {
        val notificacoes = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (notificacoes.currentInterruptionFilter > NotificationManager.INTERRUPTION_FILTER_ALL) {
            return "nada" // Não perturbe ligado.
        }
        val audio = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        if (audio.ringerMode == AudioManager.RINGER_MODE_NORMAL) {
            val id = ids[nome] ?: return "nada"
            sons?.play(id, 1f, 1f, 1, 0, 1f)
            return "som"
        }
        vibrar(nome)
        return "vibrou"
    }

    private fun vibrar(nome: String) {
        val vibrador: Vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager).defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
        if (!vibrador.hasVibrator()) return
        // Pausa, vibra, pausa, vibra... (em milissegundos).
        val padrao = when (nome) {
            "recorde" -> longArrayOf(0, 80, 60, 80, 60, 250)
            "conquista" -> longArrayOf(0, 60, 50, 120)
            else -> longArrayOf(0, 150)
        }
        vibrador.vibrate(VibrationEffect.createWaveform(padrao, -1))
    }

    override fun onDestroy() {
        sons?.release()
        sons = null
        super.onDestroy()
    }
}
