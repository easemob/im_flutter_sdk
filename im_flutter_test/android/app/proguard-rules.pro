# 环信 SDK 的 push 模块引用了可选的厂商推送 SDK（OPPO/魅族/vivo/小米）。
# 本测试工程未集成这些厂商推送依赖，release 构建时 R8 会报 Missing class。
# 这些类仅在对应厂商推送场景才被调用，本项目不用推送，忽略是安全的。
-dontwarn com.heytap.msp.push.**
-dontwarn com.meizu.cloud.pushsdk.**
-dontwarn com.vivo.push.**
-dontwarn com.xiaomi.mipush.sdk.**

# 环信 SDK 的 jar 未自带 consumer proguard 规则，但其原生库（libhyphenate.so 等）
# 通过 JNI 按类名查找 com.hyphenate.chat.adapter.** 等 Java 类，R8 混淆改名会导致
# ClassNotFoundException 崩溃（实测：EMAREncryptUtils）。
# 整体保留环信 SDK，不做混淆。
-keep class com.hyphenate.** { *; }
-dontwarn com.hyphenate.**

# ReLinker（原生库加载器）也通过反射加载 so，保留避免混淆破坏。
-keep class internal.com.getkeepsafe.relinker.** { *; }
-dontwarn internal.com.getkeepsafe.relinker.**
