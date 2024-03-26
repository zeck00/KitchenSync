package com.example.kitchensync

import android.app.AlarmManager
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.kitchensync/alarm_permission"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestExactAlarmPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        if (!hasExactAlarmPermission()) {
                            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
                            startActivity(intent)
                            result.success(true)
                        } else {
                            result.success(false) // Permission already granted, no need to ask again.
                        }
                    } else {
                        result.success(false) // Not Android 12 or above, so this isn't applicable.
                    }
                }
                "checkExactAlarmPermission" -> {
                    result.success(hasExactAlarmPermission())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasExactAlarmPermission(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            return (getSystemService(ALARM_SERVICE) as AlarmManager).canScheduleExactAlarms()
        }
        return true // For below Android S, assume it's always granted as the permission isn't needed.
    }
}
