package com.example.appresourcemonitor

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.TrafficStats
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.system.Os
import android.system.OsConstants
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import kotlin.math.max

class MainActivity : FlutterActivity() {
    private val methodChannelName = "app_resource_monitor/methods"
    private val eventChannelName = "app_resource_monitor/snapshots"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val collector = AndroidResourceCollector(this)
        val actions = AndroidAppActionRunner(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelName)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "fetchSnapshots" -> result.success(collector.fetchSnapshots())
                        "stopBackground" -> result.success(actions.stopBackground(call.platformId()))
                        "uninstall" -> result.success(actions.uninstall(call.platformId()))
                        else -> result.notImplemented()
                    }
                } catch (error: Throwable) {
                    result.error(
                        "ANDROID_RESOURCE_MONITOR_FAILED",
                        error.message ?: "Android resource monitor failed",
                        null,
                    )
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannelName)
            .setStreamHandler(AndroidSnapshotStream(collector))
    }
}

private fun MethodCall.platformId(): String {
    val arguments = arguments as? Map<*, *>
    return arguments?.get("platformId") as? String
        ?: arguments?.get("id") as? String
        ?: error("Missing platformId")
}

private class AndroidSnapshotStream(
    private val collector: AndroidResourceCollector,
) : EventChannel.StreamHandler {
    private val handler = Handler(Looper.getMainLooper())
    private var sink: EventChannel.EventSink? = null

    private val tick =
        object : Runnable {
            override fun run() {
                sink?.success(collector.fetchSnapshots())
                handler.postDelayed(this, 5000)
            }
        }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        tick.run()
    }

    override fun onCancel(arguments: Any?) {
        handler.removeCallbacks(tick)
        sink = null
    }
}

private class AndroidResourceCollector(private val context: Context) {
    private val packageManager = context.packageManager
    private val activityManager =
        context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    private val clockTicks = Os.sysconf(OsConstants._SC_CLK_TCK).toDouble()
    private val cpuCores = max(1, Runtime.getRuntime().availableProcessors())
    private val lastNetworkSamples = mutableMapOf<Int, NetworkSample>()

    fun fetchSnapshots(): List<Map<String, Any?>> {
        val processes = scanProcesses()
        val processesByUid = processes.groupBy { it.uid }
        val processesByName = processes.associateBy { it.name }
        val memoryClassMb = max(1, activityManager.memoryClass)
        val sampledAt = isoNow()

        return installedApplications()
            .sortedBy { labelFor(it).lowercase(Locale.getDefault()) }
            .map { app ->
                val packageName = app.packageName
                val appProcesses =
                    processesByUid[app.uid].orEmpty().filter {
                        it.name == packageName || it.name.startsWith("$packageName:")
                    }.ifEmpty {
                        listOfNotNull(processesByName[packageName])
                    }
                val memoryMb = appProcesses.sumOf { it.rssKb }.toDouble() / 1024.0
                val cpuPercent = appProcesses.sumOf { it.cpuPercent }.coerceIn(0.0, 100.0)
                val diskMb = diskUsageMb(app)
                val networkKbPerSecond = networkRateKbPerSecond(app.uid)

                mapOf(
                    "app" to
                        mapOf(
                            "id" to packageName,
                            "name" to labelFor(app),
                            "platformId" to packageName,
                            "iconHint" to "android",
                        ),
                    "isRunning" to appProcesses.isNotEmpty(),
                    "cpu" to metric("CPU", cpuPercent, "%", cpuPercent),
                    "memory" to
                        metric(
                            "内存",
                            memoryMb,
                            "MB",
                            percent(memoryMb, memoryClassMb.toDouble()),
                        ),
                    "disk" to
                        metric(
                            "磁盘",
                            diskMb,
                            "MB",
                            percent(diskMb, 1024.0),
                        ),
                    "network" to
                        metric(
                            "网络",
                            networkKbPerSecond,
                            "KB/s",
                            percent(networkKbPerSecond, 1024.0),
                        ),
                    "sampledAt" to sampledAt,
                    "source" to "android:/proc+TrafficStats",
                )
            }
    }

    private fun installedApplications(): List<ApplicationInfo> {
        return packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
            .filter { app ->
                val launchIntent = packageManager.getLaunchIntentForPackage(app.packageName)
                launchIntent != null || (app.flags and ApplicationInfo.FLAG_SYSTEM) == 0
            }
    }

    private fun labelFor(app: ApplicationInfo): String {
        return packageManager.getApplicationLabel(app).toString()
    }

    private fun scanProcesses(): List<ProcessSample> {
        val uptimeSeconds = readUptimeSeconds()
        return File("/proc")
            .listFiles()
            .orEmpty()
            .asSequence()
            .filter { it.isDirectory && it.name.all(Char::isDigit) }
            .mapNotNull { readProcessSample(it, uptimeSeconds) }
            .toList()
    }

    private fun readProcessSample(dir: File, uptimeSeconds: Double): ProcessSample? {
        val pid = dir.name.toIntOrNull() ?: return null
        val status = dir.resolve("status").readTextOrNull() ?: return null
        val uid =
            Regex("""(?m)^Uid:\s+(\d+)""").find(status)?.groupValues?.get(1)?.toIntOrNull()
                ?: return null
        val rssKb =
            Regex("""(?m)^VmRSS:\s+(\d+)""").find(status)?.groupValues?.get(1)?.toLongOrNull()
                ?: 0L
        val cmdline =
            dir.resolve("cmdline").readTextOrNull()
                ?.replace('\u0000', ' ')
                ?.trim()
                ?.takeIf { it.isNotBlank() }
        val name =
            cmdline
                ?: Regex("""(?m)^Name:\s+(.+)$""").find(status)?.groupValues?.get(1)
                ?: return null
        val stat = dir.resolve("stat").readTextOrNull() ?: return null
        val cpuPercent = processCpuPercent(stat, uptimeSeconds)
        return ProcessSample(pid, uid, name, rssKb, cpuPercent)
    }

    private fun processCpuPercent(stat: String, uptimeSeconds: Double): Double {
        val endOfName = stat.lastIndexOf(')')
        if (endOfName < 0) return 0.0
        val fields = stat.substring(endOfName + 2).split(' ')
        val userTicks = fields.getOrNull(11)?.toDoubleOrNull() ?: return 0.0
        val systemTicks = fields.getOrNull(12)?.toDoubleOrNull() ?: return 0.0
        val startTicks = fields.getOrNull(19)?.toDoubleOrNull() ?: return 0.0
        val elapsedSeconds = uptimeSeconds - (startTicks / clockTicks)
        if (elapsedSeconds <= 0.0) return 0.0
        val cpuSeconds = (userTicks + systemTicks) / clockTicks
        return (cpuSeconds / elapsedSeconds / cpuCores.toDouble()) * 100.0
    }

    private fun diskUsageMb(app: ApplicationInfo): Double {
        val apkBytes = File(app.sourceDir).length().coerceAtLeast(0L)
        val rootDataKb = RootShell.run("du -sk ${shellQuote(app.dataDir)}")
            ?.lineSequence()
            ?.firstOrNull()
            ?.trim()
            ?.split(Regex("""\s+"""))
            ?.firstOrNull()
            ?.toLongOrNull()
        return if (rootDataKb != null) {
            rootDataKb.toDouble() / 1024.0
        } else {
            apkBytes.toDouble() / 1024.0 / 1024.0
        }
    }

    private fun networkRateKbPerSecond(uid: Int): Double {
        val rx = TrafficStats.getUidRxBytes(uid)
        val tx = TrafficStats.getUidTxBytes(uid)
        val totalBytes = listOf(rx, tx).filter { it != TrafficStats.UNSUPPORTED.toLong() }.sum()
        if (totalBytes <= 0L) return 0.0

        val nowMillis = System.currentTimeMillis()
        val previous = lastNetworkSamples.put(uid, NetworkSample(totalBytes, nowMillis))
        if (previous == null) return 0.0

        val elapsedSeconds = (nowMillis - previous.sampledAtMillis).toDouble() / 1000.0
        if (elapsedSeconds <= 0.0) return 0.0

        val deltaBytes = max(0L, totalBytes - previous.totalBytes)
        return deltaBytes.toDouble() / 1024.0 / elapsedSeconds
    }

    private fun metric(label: String, value: Double, unit: String, percent: Double): Map<String, Any> {
        return mapOf(
            "label" to label,
            "value" to rounded(value),
            "unit" to unit,
            "percent" to percent.coerceIn(0.0, 100.0),
        )
    }

    private fun readUptimeSeconds(): Double {
        return File("/proc/uptime")
            .readTextOrNull()
            ?.split(' ')
            ?.firstOrNull()
            ?.toDoubleOrNull()
            ?: 0.0
    }
}

private class AndroidAppActionRunner(private val context: Context) {
    fun stopBackground(packageName: String): Map<String, String> {
        val rootResult = RootShell.run("am force-stop ${shellQuote(packageName)}")
        if (rootResult != null) {
            return actionResult("success", "已通过 Root 命令尝试关闭 $packageName。")
        }

        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        activityManager.killBackgroundProcesses(packageName)
        return actionResult(
            "permissionRequired",
            "已调用普通后台清理接口；完整关闭需要 Root 权限。",
        )
    }

    fun uninstall(packageName: String): Map<String, String> {
        val rootResult = RootShell.run("pm uninstall ${shellQuote(packageName)}")
        if (rootResult != null && !rootResult.contains("Failure", ignoreCase = true)) {
            return actionResult("success", "已通过 Root 命令尝试卸载 $packageName。")
        }

        val intent =
            Intent(Intent.ACTION_DELETE, Uri.parse("package:$packageName")).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        context.startActivity(intent)
        return actionResult("unsupported", "普通环境已打开系统卸载入口，静默卸载需要 Root 权限。")
    }

    private fun actionResult(status: String, message: String): Map<String, String> {
        return mapOf("status" to status, "message" to message)
    }
}

private object RootShell {
    fun run(command: String): String? {
        return try {
            val process = ProcessBuilder("su", "-c", command).redirectErrorStream(true).start()
            val output = process.inputStream.bufferedReader().readText()
            val exitCode = process.waitFor()
            if (exitCode == 0) output else null
        } catch (_: Throwable) {
            null
        }
    }
}

private data class ProcessSample(
    val pid: Int,
    val uid: Int,
    val name: String,
    val rssKb: Long,
    val cpuPercent: Double,
)

private data class NetworkSample(
    val totalBytes: Long,
    val sampledAtMillis: Long,
)

private fun File.readTextOrNull(): String? {
    return try {
        readText()
    } catch (_: Throwable) {
        null
    }
}

private fun shellQuote(value: String): String {
    return "'${value.replace("'", "'\"'\"'")}'"
}

private fun percent(value: Double, whole: Double): Double {
    if (whole <= 0.0) return 0.0
    return (value / whole * 100.0).coerceIn(0.0, 100.0)
}

private fun rounded(value: Double): Double {
    return kotlin.math.round(value * 10.0) / 10.0
}

private fun isoNow(): String {
    return SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US).format(Date())
}
