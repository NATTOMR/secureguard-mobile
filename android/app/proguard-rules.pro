# SecurePulse Mobile — ProGuard / R8 Optimization & Obfuscation Rules

# Flutter Engine Preservation
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Hardware Biometric Authentication (local_auth)
-keep class androidx.biometric.** { *; }
-dontwarn androidx.biometric.**

# Android KeyStore & Secure Storage (flutter_secure_storage)
-keep class androidx.security.crypto.** { *; }
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# Firebase Cloud Messaging & Core
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Play Core & Deferred Components
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Prevent obfuscation of serialization attributes
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep generic types and JSON serializable classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
