# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# Keep app entry point
-keep class **.MainActivity { *; }

# Supabase / Ktor websocket (realtime channel)
-keep class io.github.jan.supabase.** { *; }
-keep class io.ktor.** { *; }
-dontwarn io.ktor.**
-keep class kotlinx.serialization.** { *; }
-dontwarn kotlinx.serialization.**
-keep @kotlinx.serialization.Serializable class * { *; }

# flutter_quill — Delta JSON serialization must survive shrinking
-keep class com.flutter.quill.** { *; }
-keep class com.google.** { *; }
-dontwarn com.google.**

# audio_waveforms
-keep class com.simform.audio_waveforms.** { *; }
-dontwarn com.simform.**

# flutter_local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.**

# image_picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# OkHttp (used by Supabase under the hood)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
