package com.example.tras_phone

import android.content.pm.PackageManager
import android.os.Build
import android.os.Debug
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.StandardIntegrityManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.net.InetSocketAddress
import java.net.Socket

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "com.trasphone/security"
    private var integrityTokenProvider: StandardIntegrityManager.StandardIntegrityTokenProvider? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSecuritySignals" -> result.success(buildSecuritySignals())
                "prepareIntegrityTokenProvider" -> {
                    val rawProjectNumber = call.argument<String>("cloudProjectNumber")
                    if (rawProjectNumber.isNullOrBlank()) {
                        result.error(
                            "integrity/missing-project-number",
                            "Missing Play Integrity cloud project number",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    prepareIntegrityTokenProvider(rawProjectNumber, result)
                }
                "requestIntegrityToken" -> {
                    val requestHash = call.argument<String>("requestHash")
                    if (requestHash.isNullOrBlank()) {
                        result.error(
                            "integrity/missing-request-hash",
                            "Missing integrity request hash",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    requestIntegrityToken(requestHash, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun prepareIntegrityTokenProvider(
        rawProjectNumber: String,
        result: MethodChannel.Result,
    ) {
        if (integrityTokenProvider != null) {
            result.success(null)
            return
        }

        val cloudProjectNumber = rawProjectNumber.toLongOrNull()
        if (cloudProjectNumber == null) {
            result.error(
                "integrity/invalid-project-number",
                "Invalid Play Integrity cloud project number",
                null,
            )
            return
        }

        val integrityManager = IntegrityManagerFactory.createStandard(applicationContext)
        integrityManager.prepareIntegrityToken(
            StandardIntegrityManager.PrepareIntegrityTokenRequest.builder()
                .setCloudProjectNumber(cloudProjectNumber)
                .build(),
        ).addOnSuccessListener { provider ->
            integrityTokenProvider = provider
            result.success(null)
        }.addOnFailureListener { exception ->
            result.error(
                "integrity/prepare-failed",
                exception.message,
                null,
            )
        }
    }

    private fun requestIntegrityToken(
        requestHash: String,
        result: MethodChannel.Result,
    ) {
        val provider = integrityTokenProvider
        if (provider == null) {
            result.error(
                "integrity/not-prepared",
                "Integrity token provider is not prepared",
                null,
            )
            return
        }

        provider.request(
            StandardIntegrityManager.StandardIntegrityTokenRequest.builder()
                .setRequestHash(requestHash)
                .build(),
        ).addOnSuccessListener { response ->
            result.success(response.token())
        }.addOnFailureListener { exception ->
            result.error(
                "integrity/request-failed",
                exception.message,
                null,
            )
        }
    }

    private fun buildSecuritySignals(): Map<String, Any?> {
        val issues = mutableListOf<String>()
        val isDebuggable = (applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0
        val isDebuggerAttached = Debug.isDebuggerConnected() || Debug.waitingForDebugger()
        val isEmulator = isProbablyEmulator()
        val hasTestKeys = Build.TAGS?.contains("test-keys") == true
        val hasRootFiles = hasAnyFile(
            "/system/xbin/su",
            "/system/bin/su",
            "/sbin/su",
            "/su/bin/su",
            "/system/app/Superuser.apk",
        )
        val hasMagiskFiles = hasAnyFile(
            "/sbin/magisk",
            "/cache/.disable_magisk",
            "/dev/.magisk.unblock",
            "/data/adb/magisk",
        )
        val hasHookFramework = hasAnyInstalledPackage(
            "de.robv.android.xposed.installer",
            "org.meowcat.edxposed.manager",
            "com.saurik.substrate",
            "io.github.vvb2060.magisk",
        )
        val hasFridaServer = isLocalPortOpen(27042) || isLocalPortOpen(27043)

        if (isDebuggable) issues.add("debuggable_build")
        if (isDebuggerAttached) issues.add("debugger_attached")
        if (isEmulator) issues.add("emulator_detected")
        if (hasTestKeys) issues.add("test_keys_detected")
        if (hasRootFiles) issues.add("root_artifacts_detected")
        if (hasMagiskFiles) issues.add("magisk_artifacts_detected")
        if (hasHookFramework) issues.add("hook_framework_detected")
        if (hasFridaServer) issues.add("frida_server_detected")

        return mapOf(
            "platform" to "android",
            "isDebuggable" to isDebuggable,
            "isDebuggerAttached" to isDebuggerAttached,
            "isEmulator" to isEmulator,
            "hasTestKeys" to hasTestKeys,
            "hasRootFiles" to hasRootFiles,
            "hasMagiskFiles" to hasMagiskFiles,
            "hasHookFramework" to hasHookFramework,
            "hasFridaServer" to hasFridaServer,
            "packageName" to packageName,
            "appVersion" to packageManager.getPackageInfo(packageName, 0).versionName,
            "issues" to issues,
        )
    }

    private fun hasAnyFile(vararg paths: String): Boolean = paths.any { File(it).exists() }

    private fun hasAnyInstalledPackage(vararg packageNames: String): Boolean =
        packageNames.any { packageName ->
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    packageManager.getPackageInfo(
                        packageName,
                        PackageManager.PackageInfoFlags.of(0),
                    )
                } else {
                    @Suppress("DEPRECATION")
                    packageManager.getPackageInfo(packageName, 0)
                }
                true
            } catch (_: Exception) {
                false
            }
        }

    private fun isLocalPortOpen(port: Int): Boolean {
        return try {
            Socket().use { socket ->
                socket.connect(InetSocketAddress("127.0.0.1", port), 150)
                true
            }
        } catch (_: Exception) {
            false
        }
    }

    private fun isProbablyEmulator(): Boolean {
        return Build.FINGERPRINT.startsWith("generic") ||
            Build.FINGERPRINT.lowercase().contains("emulator") ||
            Build.MODEL.contains("google_sdk") ||
            Build.MODEL.contains("Emulator") ||
            Build.MODEL.contains("Android SDK built for x86") ||
            Build.MANUFACTURER.contains("Genymotion") ||
            Build.HARDWARE.contains("goldfish") ||
            Build.HARDWARE.contains("ranchu") ||
            Build.PRODUCT.contains("sdk") ||
            Build.PRODUCT.contains("emulator") ||
            Build.PRODUCT.contains("simulator")
    }
}
