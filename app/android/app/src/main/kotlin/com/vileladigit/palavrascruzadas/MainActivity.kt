package com.vileladigit.palavrascruzadas

import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.SoundPool
import android.os.Build
import android.view.HapticFeedbackConstants
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Sons e vibração seguindo o modo do celular, sem pedir nada à pessoa:
 * - modo Som: toca o som;
 * - modo Vibrar ou Silencioso: só a vibração de toque do celular;
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

    /**
     * Vibração de toque do próprio Android (a mesma do teclado). Não precisa
     * de permissão e segue a configuração de vibração do celular: se a pessoa
     * desligou a vibração de toque, nada acontece.
     */
    private fun vibrar(nome: String) {
        val tela = window?.decorView ?: return
        val efeito = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            HapticFeedbackConstants.CONFIRM
        } else {
            HapticFeedbackConstants.LONG_PRESS
        }
        tela.performHapticFeedback(efeito)
        if (nome == "recorde" || nome == "conquista") {
            tela.postDelayed({ tela.performHapticFeedback(efeito) }, 180)
        }
    }

    override fun onDestroy() {
        sons?.release()
        sons = null
        super.onDestroy()
    }
}
