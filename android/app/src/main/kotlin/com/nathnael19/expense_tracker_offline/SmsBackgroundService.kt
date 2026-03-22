package com.nathnael19.expense_tracker_offline

import android.app.Service
import android.content.Intent
import android.os.IBinder
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.view.FlutterCallbackInformation
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class SmsBackgroundService : Service() {

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val body = intent?.getStringExtra("body")
        val address = intent?.getStringExtra("address")
        val date = intent?.getLongExtra("date", System.currentTimeMillis()) ?: System.currentTimeMillis()
        val callbackHandle = intent?.getLongExtra("callbackHandle", 0L) ?: 0L

        if (body != null && callbackHandle != 0L) {
            handleBackgroundSms(body, address, date, callbackHandle)
        }

        return START_NOT_STICKY
    }

    private fun handleBackgroundSms(body: String, address: String?, date: Long, callbackHandle: Long) {
        val loader = FlutterLoader()
        loader.startInitialization(this)
        loader.ensureInitializationComplete(this, null)

        val engine = FlutterEngine(this)
        val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)
        
        if (callbackInfo == null) {
            Log.e("SmsBackgroundService", "Fatal: failed to find callback information")
            stopSelf()
            return
        }

        val dartBundlePath = loader.findAppBundlePath()
        val entryPoint = DartExecutor.DartCallback(assets, dartBundlePath, callbackInfo)
        
        engine.dartExecutor.executeDartCallback(entryPoint)

        // Use a method channel to send the data to the background isolate
        val backgroundChannel = MethodChannel(engine.dartExecutor.binaryMessenger, "com.nathnael19.expense_tracker_offline/sms_background")
        
        // We need to wait for the isolate to be ready, but for simplicity, 
        // we can just send the data if the isolate is already running or use an Initial argument.
        // Actually, the handleBackgroundSms static method in Dart takes the event as an argument if called via a specific plugin,
        // but here we are starting the isolate with THAT function as entry point directly.
        // So we should pass the data via a MethodChannel AFTER it starts.
        
        backgroundChannel.setMethodCallHandler { call, result ->
            if (call.method == "ready") {
                val map = mapOf("body" to body, "address" to address, "date" to date)
                result.success(map)
                // Once data is sent, we can stop the engine after some delay or once Dart confirms processing
            } else if (call.method == "finished") {
                engine.destroy()
                stopSelf()
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
