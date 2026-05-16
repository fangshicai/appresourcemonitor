# App Resource Monitor Agent Guide

## 项目定位

本项目是一个 Flutter 资源监控研究型 App，目标适配 Android 和 iOS。应用用于展示设备中每个程序的运行状态和资源占用，包括程序是否开启、CPU、内存、磁盘占用、使用率占比、确切资源数值，并提供关闭后台和卸载入口。

当前阶段以 Root/Jailbreak 研究版为主线，不按普通 App Store 或 Play Store 上架能力设计。普通 Android 权限和 iOS 沙盒无法完整实现监控、关闭、卸载其他 App 的能力；这些能力必须通过 Root、Jailbreak、系统级授权、企业受控环境或研究环境提供。

## 技术栈与架构

- Flutter + Dart 作为跨平台 UI 和业务编排层。
- GetX 用于路由管理、依赖绑定和状态管理。
- MVVM 作为主要分层模型。
- Android 原生侧优先使用 Kotlin。
- iOS 原生侧优先使用 Swift，必要时可使用 Objective-C/Objective-C++ 兼容低层能力。
- Flutter 与原生能力通过 MethodChannel 和 EventChannel 连接。

推荐数据流：

```text
View -> ViewModel/Controller -> Repository/Service -> PlatformResourceBridge -> Native Provider -> Root/Jailbreak Provider
```

## 插件选型

- `get`：用于路由管理、依赖注入和状态管理，是本项目 MVVM + GetX 规范的核心插件。
- `dio`：作为主网络请求库，用于后端 API、远程配置、诊断日志上传、资源快照同步等需要统一拦截、超时、错误处理和请求配置的场景。
- `json_serializable`：用于 JSON 序列化代码生成，适配接口模型、缓存模型、平台通道返回数据和 `AppResourceSnapshot` 等结构化数据。
- `shared_preferences`：用于保存简单本地配置，例如首次启动状态、排序筛选偏好、刷新间隔、风险提示确认状态等少量 key-value 数据。
- `connectivity_plus`：用于监听网络状态，适配远程配置、日志上传、企业后台同步等依赖网络的能力。
- 其他组件按需使用；`http`、`freezed`、`hive`、`isar`、`sqflite` 等不作为当前默认选型，只有在功能复杂度需要时再引入。

本地 `.agents/skills` 中的示例若推荐 `http`、`go_router`、`ChangeNotifier`、`provider` 或 `get_it`，仅作为通用 Flutter 指导参考；本项目实现时优先遵循本文件约定的 GetX、Dio、`json_serializable` 和 MVVM 分层。

## 文件与目录命名

- Dart 源文件使用首字母大写命名，例如 `AppResourceSnapshot.dart`、`ResourceMonitorController.dart`。
- 目录使用小写命名，例如 `models`、`services`、`controllers`、`platform_bridge`。
- 自动生成文件、测试文件和平台桥接相关文件也应尽量保持同一命名约定；若第三方工具生成固定命名，可保留工具默认命名。

## MVVM + GetX 规范

- View 只负责渲染和用户交互，不直接调用平台通道。
- ViewModel/Controller 负责页面状态、加载流程、筛选排序、错误状态和用户动作协调。
- Repository/Service 负责业务接口组合、缓存策略和平台服务调用。
- Platform Bridge 负责 Flutter 与 Android/iOS 原生实现之间的稳定边界。
- GetX Binding 负责页面依赖注入，禁止在 View 中散落创建核心服务。
- GetX Route 统一集中声明，页面不得硬编码跨模块跳转细节。

## 后续公共接口约定

本阶段只约定接口，不创建业务代码。后续实现时保持这些抽象边界：

- `AppResourceMonitorService`：获取应用列表、资源快照、刷新监控状态。
- `AppActionService`：关闭后台进程、触发卸载。
- `PlatformResourceBridge`：Flutter 与 Android/iOS 原生能力之间的桥接边界。
- `AppResourceSnapshot`：应用名、包名或 Bundle ID、运行状态、CPU、内存、磁盘、百分比数据。

## 功能目标

- 应用列表：展示可监控程序、运行状态、包名或 Bundle ID。
- CPU：展示进程 CPU 使用率和可读数值。
- 内存：展示 RSS/PSS/占比等平台可获得指标，并在 UI 中明确指标含义。
- 磁盘：展示应用数据、缓存或沙盒目录占用，按平台可获得范围实现。
- 关闭后台：Root/Jailbreak 研究版可调用高权限命令；普通环境只能给出不可用状态或系统设置入口。
- 卸载入口：Android 可使用系统卸载 Intent 或 Root 命令；iOS 普通环境不可卸载其他 App，Jailbreak 研究版需单独实现并明确风险。

## 平台与权限边界

- Android 普通应用无法稳定读取其他 App 的完整 CPU、内存、磁盘信息，也无法静默关闭或卸载任意应用。
- Android Root 研究版可以通过 `/proc`、`dumpsys`、`pm`、`am force-stop`、`du` 等能力组合实现更多数据采集和动作。
- iOS 普通应用不能枚举、监控、关闭或卸载其他 App。
- iOS Jailbreak 研究版可探索系统进程、应用容器和 SpringBoard/launchd 相关能力，但兼容性、稳定性和安全风险高。
- 所有高权限动作必须在 UI 和文档中提示风险，不应伪装成普通用户权限能力。

## 禁止事项

- 不要把 Root/Jailbreak 命令写死在 View 层。
- 不要在没有权限检查和失败状态的情况下调用关闭或卸载动作。
- 不要声称 iOS 普通上架应用能监控或管理其他 App。
- 不要把平台实现细节泄漏到 ViewModel 的 UI 状态之外。
- 不要在当前文档阶段生成业务代码、路由代码或原生能力代码。

## 已安装 Agent Skills

项目使用官方 Flutter 和 Dart Agent Skills，安装目标为 `.agents/skills`。

来源：

- Flutter Skills: `flutter/skills`
- Dart Skills: `dart-lang/skills`

官方安装命令：

```bash
npx skills add flutter/skills --skill '*' --agent universal
npx skills add dart-lang/skills --skill '*' --agent universal
```

当前环境没有可用的 `npx`，因此本项目通过克隆官方仓库并复制 `skills/*` 到 `.agents/skills` 的等价方式安装。
