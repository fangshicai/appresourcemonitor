package com.example.appresourcemonitor

import android.app.Activity
import android.app.ActivityManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.TrafficStats
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.system.Os
import android.system.OsConstants
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import kotlin.math.max
import kotlin.system.exitProcess

private const val LogTag = "AppResMonitor"
private const val UninstallRequestCode = 8101
private const val RecentUsageWindowMillis = 30 * 60 * 1000L

class MainActivity : FlutterActivity() {
    private val methodChannelName = "app_resource_monitor/methods"
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.i(LogTag, "资源监控 MainActivity 已启动，准备初始化 Flutter 原生通道。")
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.i(LogTag, "资源监控原生层开始注册 MethodChannel。")

        val collector = AndroidResourceCollector(this)
        val actions = AndroidAppActionRunner(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelName)
            .setMethodCallHandler { call, result ->
                try {
                    Log.i(LogTag, "收到 Flutter 方法调用：${call.method}。")
                    when (call.method) {
                        "fetchSnapshots" -> {
                            Thread {
                                try {
                                    val snapshots = collector.fetchSnapshots()
                                    Log.i(LogTag, "fetchSnapshots 采集完成：${snapshots.size} 个应用快照。")
                                    mainHandler.post { result.success(snapshots) }
                                } catch (error: Throwable) {
                                    Log.e(LogTag, "后台采集 fetchSnapshots 失败。", error)
                                    mainHandler.post {
                                        result.error(
                                            "ANDROID_RESOURCE_MONITOR_FAILED",
                                            error.message ?: "Android resource monitor failed",
                                            null,
                                        )
                                    }
                                }
                            }.start()
                        }
                        "stopBackground" -> result.success(actions.stopBackground(call.platformId()))
                        "uninstall" -> result.success(actions.uninstall(call.platformId()))
                        else -> result.notImplemented()
                    }
                } catch (error: Throwable) {
                    Log.e(LogTag, "原生方法调用失败：${call.method}。", error)
                    result.error(
                        "ANDROID_RESOURCE_MONITOR_FAILED",
                        error.message ?: "Android resource monitor failed",
                        null,
                    )
                }
            }

        Log.i(LogTag, "资源监控原生通道注册完成。")
    }

    @Deprecated("Android platform callback is still useful for logging uninstall result.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != UninstallRequestCode) {
            return
        }

        val resultLabel =
            when (resultCode) {
                Activity.RESULT_OK -> "用户确认，系统卸载流程返回成功"
                Activity.RESULT_CANCELED -> "用户取消，或系统未完成卸载"
                else -> "系统返回未知结果码 $resultCode"
            }
        Log.i(LogTag, "系统卸载入口返回：$resultLabel。data=$data")
    }
}

private fun MethodCall.platformId(): String {
    val arguments = arguments as? Map<*, *>
    return arguments?.get("platformId") as? String
        ?: arguments?.get("id") as? String
        ?: error("Missing platformId")
}

private class AndroidResourceCollector(private val context: Context) {
    private val packageManager = context.packageManager
    private val activityManager =
        context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    private val clockTicks = Os.sysconf(OsConstants._SC_CLK_TCK).toDouble()
    private val cpuCores = max(1, Runtime.getRuntime().availableProcessors())
    private val lastNetworkSamples = mutableMapOf<Int, NetworkSample>()
    private var diskFallbackLogged = false

    fun fetchSnapshots(): List<Map<String, Any?>> {
        val processes = scanProcesses()
        val processesByUid = processes.groupBy { it.uid }
        val processesByName = processes.associateBy { it.name }
        val memoryClassMb = max(1, activityManager.memoryClass)
        val sampledAt = isoNow()
        val applications = installedApplications()
        val rootAvailable = RootShell.isAvailable()
        val usageSnapshot = usageSnapshot()
        Log.i(
            LogTag,
            "开始生成资源快照：已扫描进程 ${processes.size} 个，可见应用 ${applications.size} 个，"
                + "Root=${if (rootAvailable) "可用" else "不可用"}，"
                + "前台应用=${usageSnapshot.foregroundPackage ?: "未知"}。",
        )

        return applications
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
                val diskMb = diskUsageMb(app, rootAvailable)
                val networkKbPerSecond = networkRateKbPerSecond(app.uid)
                val isRunning = appProcesses.isNotEmpty()
                val runState =
                    if (rootAvailable) {
                        when {
                            !isRunning -> "stopped"
                            packageName == usageSnapshot.foregroundPackage -> "foreground"
                            else -> "background"
                        }
                    } else {
                        when {
                            isRunning -> "confirmed"
                            packageName in usageSnapshot.recentPackages -> "recentlyUsed"
                            else -> "unknown"
                        }
                    }

                mapOf(
                    "app" to
                        mapOf(
                            "id" to packageName,
                            "name" to labelFor(app),
                            "platformId" to packageName,
                            "iconHint" to "android",
                        ),
                    "isRunning" to isRunning,
                    "runState" to runState,
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
                    "source" to
                        if (rootAvailable) {
                            "android:root:/proc+TrafficStats"
                        } else {
                            "android:limited:/proc+UsageStats+TrafficStats"
                        },
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
        val samples = File("/proc")
            .listFiles()
            .orEmpty()
            .asSequence()
            .filter { it.isDirectory && it.name.all(Char::isDigit) }
            .mapNotNull { readProcessSample(it, uptimeSeconds) }
            .toList()
        Log.i(LogTag, "/proc 后台程序扫描完成：${samples.size} 个可读进程。")
        return samples
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

    private fun diskUsageMb(app: ApplicationInfo, rootAvailable: Boolean): Double {
        val apkBytes = File(app.sourceDir).length().coerceAtLeast(0L)
        val rootDataKb =
            if (rootAvailable) {
                RootShell.run("du -sk ${shellQuote(app.dataDir)}")
                    ?.lineSequence()
                    ?.firstOrNull()
                    ?.trim()
                    ?.split(Regex("""\s+"""))
                    ?.firstOrNull()
                    ?.toLongOrNull()
            } else {
                null
            }
        return if (rootDataKb != null) {
            rootDataKb.toDouble() / 1024.0
        } else {
            if (!diskFallbackLogged) {
                diskFallbackLogged = true
                Log.i(LogTag, "Root 数据目录大小不可用，将统一使用 APK 大小作为磁盘占用降级值。首个应用=${app.packageName}")
            }
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

    private fun usageSnapshot(): UsageSnapshot {
        val usageStatsManager =
            context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
                ?: return UsageSnapshot()
        val nowMillis = System.currentTimeMillis()
        val events =
            try {
                usageStatsManager.queryEvents(nowMillis - RecentUsageWindowMillis, nowMillis)
            } catch (error: Throwable) {
                Log.w(LogTag, "UsageStats 查询失败，非 Root 状态将降级为当前可确认或未确认：${error.message ?: "未知错误"}")
                return UsageSnapshot()
            }

        val event = UsageEvents.Event()
        var latestPackage: String? = null
        var latestTime = 0L
        val recentPackages = mutableSetOf<String>()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (
                event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND ||
                    event.eventType == UsageEvents.Event.MOVE_TO_BACKGROUND
            ) {
                recentPackages.add(event.packageName)
            }
            if (
                event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND &&
                    event.timeStamp >= latestTime
            ) {
                latestPackage = event.packageName
                latestTime = event.timeStamp
            }
        }

        if (latestPackage == null) {
            Log.i(LogTag, "未从 UsageStats 获取到前台应用，可能尚未授予使用情况访问权限。")
        }
        return UsageSnapshot(latestPackage, recentPackages)
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
        if (packageName == context.packageName) {
            Log.w(LogTag, "目标应用是当前监控 App，将直接杀死当前进程：$packageName。")
            (context as? Activity)?.finishAndRemoveTask()
            Handler(Looper.getMainLooper()).postDelayed(
                {
                    Process.killProcess(Process.myPid())
                    exitProcess(0)
                },
                150,
            )
            return actionResult("success", "已触发杀死当前 App 进程。")
        }

        val rootResult = RootShell.run("am force-stop ${shellQuote(packageName)}")
        if (rootResult != null) {
            Log.i(LogTag, "Root 关闭后台命令已执行：$packageName。")
            return actionResult("success", "已通过 Root 命令杀死 $packageName。")
        }

        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        activityManager.killBackgroundProcesses(packageName)
        Log.w(LogTag, "Root 不可用，已对 $packageName 调用普通 killBackgroundProcesses。")
        return actionResult(
            "permissionRequired",
            "已调用普通后台清理接口；非 Root 环境无法强制杀死其他 App。",
        )
    }

    fun uninstall(packageName: String): Map<String, String> {
        val rootResult = RootShell.run("pm uninstall ${shellQuote(packageName)}")
        if (rootResult != null && !rootResult.contains("Failure", ignoreCase = true)) {
            Log.i(LogTag, "Root 卸载命令已执行：$packageName。")
            return actionResult("success", "已通过 Root 命令尝试卸载 $packageName。")
        }

        val intent =
            Intent(Intent.ACTION_UNINSTALL_PACKAGE, Uri.parse("package:$packageName")).apply {
                putExtra(Intent.EXTRA_RETURN_RESULT, true)
            }
        return try {
            val activity = context as? Activity
            if (activity != null) {
                activity.startActivityForResult(intent, UninstallRequestCode)
                Log.w(LogTag, "Root 卸载不可用，已通过 ACTION_UNINSTALL_PACKAGE 打开系统卸载入口：$packageName。")
            } else {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(intent)
                Log.w(LogTag, "Root 卸载不可用，已通过新任务打开系统卸载入口：$packageName。")
            }
            actionResult("success", "已打开系统卸载确认页；请在系统页面确认卸载。")
        } catch (error: ActivityNotFoundException) {
            Log.e(LogTag, "系统卸载入口不可用：$packageName。", error)
            actionResult("failed", "系统卸载入口不可用，无法卸载 $packageName。")
        } catch (error: Throwable) {
            Log.e(LogTag, "打开系统卸载入口失败：$packageName。", error)
            actionResult("failed", "打开系统卸载入口失败：${error.message ?: "未知错误"}")
        }
    }

    private fun actionResult(status: String, message: String): Map<String, String> {
        return mapOf("status" to status, "message" to message)
    }
}

private object RootShell {
    @Volatile
    private var unavailable = false

    @Volatile
    private var unavailableLogged = false

    @Volatile
    private var availability: Boolean? = null

    fun isAvailable(): Boolean {
        availability?.let { return it }
        val available = run("id")?.contains("uid=0") == true
        availability = available
        if (!available) {
            unavailable = true
        }
        return available
    }

    fun run(command: String): String? {
        if (unavailable || availability == false) {
            return null
        }

        return try {
            val process = ProcessBuilder("su", "-c", command).redirectErrorStream(true).start()
            val output = process.inputStream.bufferedReader().readText()
            val exitCode = process.waitFor()
            if (exitCode == 0) {
                output
            } else {
                Log.w(LogTag, "Root 命令执行失败，exitCode=$exitCode，command=$command，output=$output")
                null
            }
        } catch (error: Throwable) {
            unavailable = true
            if (!unavailableLogged) {
                unavailableLogged = true
                Log.w(
                    LogTag,
                    "Root 命令不可用，后续 Root 采集和静默操作将跳过。"
                        + "首个失败命令=$command，原因=${error.message ?: "未知错误"}",
                )
            }
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

private data class UsageSnapshot(
    val foregroundPackage: String? = null,
    val recentPackages: Set<String> = emptySet(),
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
