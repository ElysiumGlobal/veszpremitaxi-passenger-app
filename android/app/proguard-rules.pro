# ------------------------------
# Flutter
# ------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep main activity
-keep class com.yourpackage.MainActivity { *; }

# Keep generated plugin registrants
-keep class io.flutter.plugins.** { *; }

# ------------------------------
# Firebase
# ------------------------------
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Firebase messaging / analytics
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.analytics.** { *; }

# Avoid warnings
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ------------------------------
# Gson
# ------------------------------
-keep class com.google.gson.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ------------------------------
# Kotlin
# ------------------------------
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# ------------------------------
# Networking: OkHttp / Retrofit / Dio
# ------------------------------
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn retrofit2.**
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }

# ------------------------------
# Room / Jetpack (if used)
# ------------------------------
-keep class androidx.room.** { *; }
-dontwarn androidx.room.**

# ------------------------------
# Enums
# ------------------------------
-keepclassmembers enum * { *; }

# ------------------------------
# Reflection / serialization
# ------------------------------
-keepclassmembers class * {
    @androidx.annotation.Keep <fields>;
}
-keepclassmembers class * {
    @androidx.annotation.Keep <methods>;
}

# ------------------------------
# Misc
# ------------------------------
-dontwarn java.nio.**
-dontwarn javax.annotation.**
-dontwarn sun.misc.**


# ------------------------------
# Flutter Deferred Components / Play Store SplitCompat
# ------------------------------
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Keep PlayStoreDeferredComponentManager classes
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Prevent stripping SLF4J (logger)
-keep class org.slf4j.** { *; }
-dontwarn org.slf4j.**


# ------------------------------
# Flutter Play Store Deferred Components
# ------------------------------
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Keep Flutter deferred component manager
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# SLF4J (sometimes used by Play Core)
-keep class org.slf4j.** { *; }
-dontwarn org.slf4j.**

# Avoid warnings for Play Core
-dontwarn com.google.android.play.core.**
