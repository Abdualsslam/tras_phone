# Keep Flutter entry points and generated plugin registrants.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Google Maps and Play Integrity APIs used via reflection / platform channels.
-keep class com.google.android.gms.maps.** { *; }
-keep class com.google.android.play.core.integrity.** { *; }
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Preserve annotations and generic signatures used by serialization and DI.
-keepattributes Signature,*Annotation*

# Avoid over-obfuscating WebView / network exceptions in crash traces.
-keep class okhttp3.** { *; }
-dontwarn javax.annotation.**
