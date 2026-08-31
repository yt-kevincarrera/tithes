package dev.selector.diezmo

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Recoge el texto que se comparte con la app —el slip de nómina desde Telegram—
 * y se lo pasa a Dart.
 *
 * Se hace a mano en vez de con un paquete porque lo único que hace falta es
 * ACTION_SEND de texto, y los paquetes que lo envuelven traen más superficie de
 * la necesaria: el que se probó primero ni siquiera compilaba con este Gradle.
 */
class MainActivity : FlutterActivity() {

    private companion object {
        const val CHANNEL = "dev.selector.diezmo/shared_text"
    }

    private var channel: MethodChannel? = null

    /**
     * Texto compartido que abrió la app, guardado hasta que Dart esté listo
     * para pedirlo. Sin esto se perdería: el intent llega antes de que exista
     * nada al otro lado.
     */
    private var pendingText: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "takeSharedText" -> {
                        result.success(pendingText)
                        // Se entrega una sola vez: si no, volver a la app
                        // reimportaría el mismo slip.
                        pendingText = null
                    }
                    else -> result.notImplemented()
                }
            }
        }

        pendingText = sharedTextOf(intent)
    }

    /** Con la app ya abierta, compartir otro slip llega por aquí. */
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        val text = sharedTextOf(intent) ?: return
        val target = channel
        if (target == null) {
            pendingText = text
        } else {
            target.invokeMethod("sharedText", text)
        }
    }

    private fun sharedTextOf(intent: Intent?): String? {
        if (intent?.action != Intent.ACTION_SEND) return null
        if (intent.type?.startsWith("text/") != true) return null
        return intent.getStringExtra(Intent.EXTRA_TEXT)?.takeIf {
            it.isNotBlank()
        }
    }
}
