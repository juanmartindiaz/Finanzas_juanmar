package com.juanmartin.gestor_finanzas

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.os.PowerManager

/**
 * Mantiene vivo el proceso de la app (y con él el servidor HTTP local) cuando
 * la interfaz pasa a segundo plano. Android exige una notificación visible
 * mientras un servicio en primer plano está activo.
 */
class ServidorService : Service() {

    private var wakeLock: PowerManager.WakeLock? = null

    override fun onCreate() {
        super.onCreate()
        crearCanal()
        startForeground(NOTIFICACION_ID, construirNotificacion())
        val powerManager = getSystemService(POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "GestorFinanzas::ServidorCapturas"
        ).apply { setReferenceCounted(false); acquire() }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(NOTIFICACION_ID, construirNotificacion())
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        wakeLock?.let { if (it.isHeld) it.release() }
        wakeLock = null
        super.onDestroy()
    }

    private fun crearCanal() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java)
        if (manager.getNotificationChannel(CANAL_ID) != null) return
        val canal = NotificationChannel(
            CANAL_ID,
            "Servidor de capturas",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Mantiene el canal local del bot de WhatsApp activo."
            setShowBadge(false)
        }
        manager.createNotificationChannel(canal)
    }

    private fun construirNotificacion(): Notification {
        val abrirApp = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            abrirApp,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CANAL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        return builder
            .setContentTitle("Gestor Finanzas")
            .setContentText("Canal del bot activo (127.0.0.1:8787)")
            .setSmallIcon(android.R.drawable.stat_notify_sync)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    companion object {
        private const val CANAL_ID = "servidor_capturas"
        private const val NOTIFICACION_ID = 4201
    }
}
