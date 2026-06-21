package com.brandingbeam.brandingbeam_attribution

import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import com.android.installreferrer.api.ReferrerDetails
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** BrandingbeamAttributionPlugin — exposes device signals + the Play Install Referrer. */
class BrandingbeamAttributionPlugin :
    FlutterPlugin,
    MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private val main = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "brandingbeam_attribution")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result,
    ) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${Build.VERSION.RELEASE}")
            "getInstallContext" -> getInstallContext(result)
            else -> result.notImplemented()
        }
    }

    private fun getInstallContext(result: Result) {
        val base =
            hashMapOf<String, Any?>(
                "platform" to "android",
                "deviceModel" to Build.MODEL,
                "osVersion" to Build.VERSION.RELEASE,
            )
        val ctx = context
        if (ctx == null) {
            result.success(base)
            return
        }

        val client = InstallReferrerClient.newBuilder(ctx).build()
        var replied = false

        fun reply(extra: Map<String, Any?>) {
            if (replied) return
            replied = true
            base.putAll(extra)
            // MethodChannel results must be delivered on the main thread.
            main.post { result.success(base) }
            try {
                client.endConnection()
            } catch (_: Exception) {
            }
        }

        try {
            client.startConnection(
                object : InstallReferrerStateListener {
                    override fun onInstallReferrerSetupFinished(responseCode: Int) {
                        if (responseCode == InstallReferrerClient.InstallReferrerResponse.OK) {
                            try {
                                val details: ReferrerDetails = client.installReferrer
                                reply(mapOf("installReferrer" to details.installReferrer))
                            } catch (e: Exception) {
                                reply(emptyMap())
                            }
                        } else {
                            reply(emptyMap())
                        }
                    }

                    override fun onInstallReferrerServiceDisconnected() {
                        reply(emptyMap())
                    }
                },
            )
        } catch (e: Exception) {
            reply(emptyMap())
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }
}
