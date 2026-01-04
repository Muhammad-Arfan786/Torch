# Flutter specific ProGuard rules

# Google Play Core library (for deferred components) - not used but referenced
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Google Fonts
-keep class com.google.** { *; }

# Keep sensor and compass classes
-keep class com.sensors_plus.** { *; }
-keep class com.hmscl.flutter_compass.** { *; }

# Keep vibration plugin
-keep class com.benjaminabel.vibration.** { *; }

# Keep torch light plugin
-keep class com.svprdga.torchlight.** { *; }

# Keep wakelock plugin
-keep class dev.fluttercommunity.plus.wakelock.** { *; }

# Keep permission handler
-keep class com.baseflow.permissionhandler.** { *; }

# Keep shared preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Prevent R8 from stripping interface information
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelables
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
