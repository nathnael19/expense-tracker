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
                // Broadcast to MainActivity via a local intent
                val localIntent = Intent("SMS_RECEIVED_LOCAL").apply {
                    putExtra("body", body)
                    putExtra("address", address)
                    putExtra("date", timestamp)
                }
                context?.sendBroadcast(localIntent)
            }
        }
    }
}
