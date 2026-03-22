package com.nathnael19.expense_tracker_offline

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            for (smsMessage in messages) {
                val body = smsMessage.messageBody ?: continue
                val address = smsMessage.originatingAddress ?: ""
                val timestamp = smsMessage.timestampMillis
                
                // 1. Send local broadcast (for active app)
                val localIntent = Intent("SMS_RECEIVED_LOCAL").apply {
                    putExtra("body", body)
                    putExtra("address", address)
                    putExtra("date", timestamp)
                    setPackage(context?.packageName)
                }
                context?.sendBroadcast(localIntent)

                // 2. Start background isolate if callback is registered
                context?.let { ctx ->
                    val prefs = ctx.getSharedPreferences("expense_tracker_prefs", Context.MODE_PRIVATE)
                    val callbackHandle = prefs.getLong("sms_callback_handle", 0L)
                    if (callbackHandle != 0L) {
                         val serviceIntent = Intent(ctx, SmsBackgroundService::class.java).apply {
                             putExtra("body", body)
                             putExtra("address", address)
                             putExtra("date", timestamp)
                             putExtra("callbackHandle", callbackHandle)
                         }
                         ctx.startService(serviceIntent)
                    }
                }
            }
        }
    }
}
