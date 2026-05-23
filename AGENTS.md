# AGENTS.md - AI 助手开发规范

## 项目概述

**项目名称**: ai_hub
**技术栈**: Flutter + Dart（主框架）+ Android 原生 Kotlin（自定义插件）
**项目类型**: AI 相关应用，内嵌 WebView 加载 AI 网页

## 目录结构规范

```
ai_hub/
├── android/                    # Android 原生代码
│   └── app/src/main/kotlin/com/example/ai_hub/
│       ├── MainActivity.kt     # 主 Activity
│       ├── plugin/             # 自定义插件目录（新增）
│       │   ├── WebViewPlugin.kt
│       │   └── AdInterceptorPlugin.kt
│       └── utils/              # 工具类目录（新增）
│           └── CookieUtils.kt
├── lib/                        # Flutter 代码
│   ├── main.dart              # 入口文件
│   ├── app.dart               # App 配置
│   ├── config/                # 配置文件
│   ├── models/                # 数据模型
│   ├── pages/                 # 页面
│   ├── providers/             # 状态管理
│   ├── services/              # 服务层
│   ├── utils/                 # 工具类
│   └── widgets/               # 组件
└── test/                      # 测试文件
```

## 技术栈详细说明

### Flutter + Dart 层

| 技术 | 用途 | 使用场景 |
|------|------|----------|
| Flutter SDK | App 主框架 | 整体应用架构 |
| Dart | 编程语言 | 所有 Flutter 代码 |
| url_launcher | 调起已安装客户端 App | 打开外部应用 |
| shared_preferences | 本地存储 | 使用频率、主题设置 |
| path_provider | 获取本地存储路径 | 文件存储路径 |
| Material Icons | 首页卡片图标 | UI 图标 |

### Android 原生 Kotlin 层

| 技术 | 用途 | 使用场景 |
|------|------|----------|
| WebView | 内嵌加载 AI 网页 | 核心功能 |
| WebViewClient | 广告请求拦截 + JS 注入 | 自定义 WebView 行为 |
| CookieManager | 登录状态持久化 | 用户认证 |
| PackageManager | 查询是否安装客户端 | 应用检测 |
| Intent | 调起客户端 App | 应用间通信 |
| SharedPreferences | 原生端存储 | 数据持久化 |
| MethodChannel | Flutter 与原生通信 | 跨平台通信 |

## 代码规范

### Dart 代码规范

```dart
// 1. 使用 snake_case 命名文件
// 例如: home_page.dart, user_model.dart

// 2. 使用 camelCase 命名变量和函数
String userName = '';
void getUserInfo() {}

// 3. 使用 PascalCase 命名类
class UserModel {}

// 4. 常量使用 camelCase 或 UPPER_SNAKE_CASE
const appVersion = '1.0.0';
const MAX_RETRY_COUNT = 3;

// 5. 导入顺序
// 1) Dart 核心库
// 2) Flutter 框架
// 3) 第三方包
// 4) 本项目文件
```

### Kotlin 代码规范

```kotlin
// 1. 使用 camelCase 命名变量和函数
var webView: WebView? = null
fun loadUrl(url: String) {}

// 2. 使用 PascalCase 命名类
class WebViewPlugin : FlutterPlugin

// 3. 使用 UPPER_SNAKE_CASE 命名常量
const val CHANNEL_NAME = "com.example.ai_hub/webview"

// 4. 包名使用全小写
package com.example.ai_hub
```

## MethodChannel 通信规范

### Channel 命名规则

```kotlin
// 格式: {域名}/{功能模块}
const val CHANNEL_WEBVIEW = "com.example.ai_hub/webview"
const val CHANNEL_AD_INTERCEPTOR = "com.example.ai_hub/ad_interceptor"
const val CHANNEL_COOKIE_MANAGER = "com.example.ai_hub/cookie_manager"
```

### 通信数据格式

```dart
// Flutter 端调用
final result = await platform.invokeMethod('methodName', {
  'key1': value1,
  'key2': value2,
});

// Kotlin 端接收
override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
        "methodName" -> {
            val key1 = call.argument<String>("key1")
            val key2 = call.argument<Int>("key2")
            // 处理逻辑
            result.success(responseData)
        }
    }
}
```

### 错误处理

```dart
// Flutter 端
try {
  final result = await platform.invokeMethod('methodName');
} on PlatformException catch (e) {
  // 处理错误
  print('Error: ${e.message}');
}
```

```kotlin
// Kotlin 端
override fun onMethodCall(call: MethodCall, result: Result) {
    try {
        // 业务逻辑
        result.success(data)
    } catch (e: Exception) {
        result.error("ERROR_CODE", e.message, null)
    }
}
```

## WebView 开发规范

### 初始化流程

```kotlin
// 1. 在 MainActivity 中初始化
class MainActivity : FlutterActivity() {
    private lateinit var webViewPlugin: WebViewPlugin
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        webViewPlugin = WebViewPlugin(this)
        webViewPlugin.configure(flutterEngine)
    }
}
```

### 广告拦截规范

```kotlin
// 拦截规则定义
private val adPatterns = listOf(
    "googleads",
    "doubleclick.net",
    "adservice",
    // ...更多广告域名
)

override fun shouldInterceptRequest(view: WebView, request: WebResourceRequest): WebResourceResponse? {
    val url = request.url.toString()
    
    // 检查是否为广告请求
    if (adPatterns.any { url.contains(it, ignoreCase = true) }) {
        // 返回空响应
        return WebResourceResponse("text/plain", "UTF-8", "".byteInputStream())
    }
    
    return super.shouldInterceptRequest(view, request)
}
```

### JS 注入规范

```kotlin
// 注入时机: 页面加载完成后
override fun onPageFinished(view: WebView, url: String?) {
    super.onPageFinished(view, url)
    
    // 注入 JavaScript
    view.evaluateJavascript("""
        (function() {
            // 隐藏广告元素
            var ads = document.querySelectorAll('.ad-container, .advertisement');
            ads.forEach(function(ad) {
                ad.style.display = 'none';
            });
        })();
    """.trimIndent(), null)
}
```

### Cookie 管理规范

```kotlin
// 保存登录状态
fun saveCookies(url: String, cookies: Map<String, String>) {
    val cookieManager = CookieManager.getInstance()
    cookies.forEach { (name, value) ->
        cookieManager.setCookie(url, "$name=$value")
    }
    cookieManager.flush()
}

// 获取登录状态
fun getCookies(url: String): String? {
    val cookieManager = CookieManager.getInstance()
    return cookieManager.getCookie(url)
}
```

## 测试规范

### Flutter 测试

```dart
// 单元测试
// 文件位置: test/
// 命名: {功能}_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:ai_hub/services/api_service.dart';

void main() {
  group('ApiService', () {
    test('should return user data', () async {
      final service = ApiService();
      final result = await service.getUserInfo();
      expect(result, isNotNull);
    });
  });
}
```

### Widget 测试

```dart
// 文件位置: test/widgets/
// 命名: {组件名}_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:ai_hub/widgets/custom_card.dart';

void main() {
  testWidgets('CustomCard displays title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomCard(title: 'Test Title'),
      ),
    );
    
    expect(find.text('Test Title'), findsOneWidget);
  });
}
```

## 常用命令

### Flutter 命令

```bash
# 获取依赖
flutter pub get

# 运行应用
flutter run

# 运行测试
flutter test

# 代码分析
flutter analyze

# 格式化代码
dart format .

# 构建 APK
flutter build apk

# 构建 App Bundle
flutter build appbundle
```

### Android 构建命令

```bash
# 在 android 目录下执行
./gradlew assembleDebug    # 调试版
./gradlew assembleRelease  # 发布版
./gradlew clean            # 清理
```

## 注意事项

### 1. 版本兼容性

- Flutter SDK: ^3.12.0
- Dart SDK: ^3.12.0
- Kotlin: 保持与项目 build.gradle 一致
- MinSdkVersion: 检查 android/app/build.gradle.kts

### 2. 权限管理

```xml
<!-- AndroidManifest.xml 中需要的权限 -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 3. 性能优化

- WebView 使用硬件加速
- 避免在主线程执行耗时操作
- 合理使用缓存策略
- 及时释放 WebView 资源

### 4. 安全规范

- 不在代码中硬编码密钥
- 使用 HTTPS 协议
- 验证输入数据
- 防止 XSS 攻击

## 提交规范

### Commit Message 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type 类型

- **feat**: 新功能
- **fix**: 修复 bug
- **docs**: 文档更新
- **style**: 代码格式（不影响功能）
- **refactor**: 重构
- **test**: 测试相关
- **chore**: 构建/工具相关

### 示例

```
feat(webview): add ad interception feature

- Implement WebViewClient with ad pattern matching
- Add JavaScript injection for hiding ad elements
- Update MethodChannel communication

Closes #123
```

## 调试技巧

### Flutter 调试

```bash
# 启用 Flutter 调试
flutter run --debug

# 使用 DevTools
flutter pub global activate devtools
dart devtools
```

### Android 调试

```bash
# 查看 Logcat
adb logcat -s Flutter

# 查看 WebView 日志
adb logcat -s chromium
```

### MethodChannel 调试

```dart
// Flutter 端
print('Calling method: $method with args: $args');

// Kotlin 端
Log.d("WebViewPlugin", "Method called: ${call.method}")
```

## 文档维护

- 代码变更时同步更新 AGENTS.md
- 新增功能需补充使用说明
- 保持代码示例与实际代码一致
