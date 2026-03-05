package com.nathnael19.expense_tracker_offline

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    companion object {
        private const val SMS_CHANNEL = "com.nathnael19.expense_tracker_offline/sms"
        private const val SMS_EVENT_CHANNEL = "com.nathnael19.expense_tracker_offline/sms_stream"
        private const val SMS_PERMISSION_REQUEST_CODE = 101
    }

    private var eventSink: EventChannel.EventSink? = null
    private var localSmsReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // MethodChannel: handle permission requests
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestSmsPermissions" -> {
                    requestSmsPermissions(result)
                }
                else -> result.notImplemented()
            }
        }

        // EventChannel: stream incoming SMS to Flutter
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    registerLocalSmsReceiver()
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    unregisterLocalSmsReceiver()
                }
            }
        )
    }

    private fun registerLocalSmsReceiver() {
        localSmsReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val body = intent?.getStringExtra("body") ?: return
                val address = intent.getStringExtra("address") ?: ""
                val date = intent.getLongExtra("date", System.currentTimeMillis())
                val map = mapOf("body" to body, "address" to address, "date" to date)
                eventSink?.success(map)
            }
        }
        val filter = IntentFilter("SMS_RECEIVED_LOCAL")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(localSmsReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(localSmsReceiver, filter)
        }
    }

    private fun unregisterLocalSmsReceiver() {
        localSmsReceiver?.let {
            try {
                unregisterReceiver(it)
            } catch (e: Exception) {
                // Already unregistered
            }
            localSmsReceiver = null
        }
    }

    private fun requestSmsPermissions(result: MethodChannel.Result) {
        val permissions = arrayOf(
            Manifest.permission.READ_SMS,
            Manifest.permission.RECEIVE_SMS
        )
        val missing = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        if (missing.isEmpty()) {
            result.success(true)
        } else {
            ActivityCompat.requestPermissions(this, missing.toTypedArray(), SMS_PERMISSION_REQUEST_CODE)
            // Return true optimistically — user will see the dialog
            result.success(true)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterLocalSmsReceiver()
    }
}
