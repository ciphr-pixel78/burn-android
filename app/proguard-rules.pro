# Burn ProGuard Rules

# Keep all Burn classes
-keep class com.burn.** { *; }
-keep interface com.burn.** { *; }
-keepnames class com.burn.** { *; }

# Device Admin Receiver
-keep class com.burn.receiver.DeviceAdminReceiver { *; }

# Services
-keep class com.burn.services.** { *; }
-keep class com.burn.services.WipeService { *; }
-keep class com.burn.services.LockscreenMonitor { *; }
-keep class com.burn.services.DeviceOwnerManager { *; }

# Keep all Activity/Service methods
-keepclassmembers class * extends android.app.Activity {
    public void *(android.view.View);
}
-keepclassmembers class * extends android.app.Service {
    public int onStartCommand(android.content.Intent, int, int);
}

# Keep BroadcastReceiver
-keepclassmembers class * extends android.content.BroadcastReceiver {
    public void onReceive(android.content.Context, android.content.Intent);
}

# Preserve line numbers for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Keep SecurityException
-keep class java.lang.SecurityException { *; }

# Kotlinx Coroutines
-keepclassmembers class kotlinx.coroutines.** {
    volatile <fields>;
}

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
