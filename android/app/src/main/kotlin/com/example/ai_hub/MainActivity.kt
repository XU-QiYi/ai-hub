package com.example.ai_hub

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.aihub.webview"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openUrl" -> {
                        val url = call.argument<String>("url")
                        if (url.isNullOrEmpty()) {
                            result.error("INVALID_URL", "URL is null or empty", null)
                        } else {
                            val intent = Intent(this, WebViewActivity::class.java)
                            intent.putExtra("url", url)
                            startActivity(intent)
                            result.success(null)
                        }
                    }
                    "checkAppInstalled" -> {
                        val packageName = call.argument<String>("packageName")
                        try {
                            packageManager.getPackageInfo(packageName!!, android.content.pm.PackageManager.MATCH_UNINSTALLED_PACKAGES)
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                    "launchApp" -> {
                        val packageName = call.argument<String>("packageName")
                        try {
                            val intent = packageManager.getLaunchIntentForPackage(packageName!!)
                            if (intent != null) {
                                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                startActivity(intent)
                                result.success(null)
                            } else {
                                // shell am start 兜底
                                val process = Runtime.getRuntime().exec(
                                    arrayOf("sh", "-c",
                                        "am start -a android.intent.action.MAIN -c android.intent.category.LAUNCHER $packageName")
                                )
                                val output = process.inputStream.bufferedReader().readText()
                                val error = process.errorStream.bufferedReader().readText()
                                process.waitFor()
                                if (output.contains("Error") || error.isNotEmpty()) {
                                    result.error("LAUNCH_FAILED", error.ifEmpty { output }, null)
                                } else {
                                    result.success(null)
                                }
                            }
                        } catch (e: Exception) {
                            result.error("LAUNCH_FAILED", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
