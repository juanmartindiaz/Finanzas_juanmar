package com.juanmartin.gestor_finanzas

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        iniciarServidorEnPrimerPlano()
        pedirPermisoNotificaciones()
    }

    /**
     * El motor Dart queda en caché y no se destruye con la actividad: el
     * servidor HTTP sigue vivo cuando la app pasa a segundo plano o se cierra
     * la tarea desde recientes. El servicio en primer plano mantiene el proceso.
     */
    override fun provideFlutterEngine(context: Context): FlutterEngine {
        val cache = FlutterEngineCache.getInstance()
        cache.get(MOTOR_ID)?.let { return it }

        val engine = FlutterEngine(context)
        GeneratedPluginRegistrant.registerWith(engine)
        cache.put(MOTOR_ID, engine)
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        return engine
    }

    override fun shouldDestroyEngineWithHost(): Boolean = false

    private fun iniciarServidorEnPrimerPlano() {
        val intent = Intent(this, ServidorService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun pedirPermisoNotificaciones() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return
        if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            return
        }
        requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 4201)
    }

    companion object {
        private const val MOTOR_ID = "gestor_finanzas_principal"
    }
}
