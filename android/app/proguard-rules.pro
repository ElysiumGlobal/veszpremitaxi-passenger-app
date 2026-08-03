-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.engine.FlutterEngine { *; }
-keepattributes *Annotation*
-dontwarn androidx.**
# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase (if using)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Gson (if using)
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# For reflection (common with plugins)
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepclassmembers class * {
    public <init>(android.content.Context);
}
