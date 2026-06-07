package com.example.vetted_club_mobile

import android.content.Context
import com.google.firebase.FirebaseApp
import com.google.firebase.appcheck.FirebaseAppCheck
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      "com.vettedclub/app_check_debug",
    ).setMethodCallHandler { call, result ->
      when (call.method) {
        "getDebugToken" -> {
          FirebaseAppCheck.getInstance()
            .getAppCheckToken(true)
            .addOnCompleteListener { task ->
              if (task.isSuccessful) {
                result.success(readAppCheckDebugSecret(applicationContext))
              } else {
                result.success(readAppCheckDebugSecret(applicationContext))
              }
            }
        }
        else -> result.notImplemented()
      }
    }
  }

  private fun readAppCheckDebugSecret(context: Context): String? {
    val app = FirebaseApp.getInstance()
    val prefsName = "com.google.firebase.appcheck.debug.store.${app.persistenceKey}"
    val prefs = context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
    return prefs.getString("com.google.firebase.appcheck.debug.DEBUG_SECRET", null)
  }
}
