# Flutter Proguard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter Deferred Components & Google Play Core references
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.appupdate.** { *; }
-keep class com.google.android.play.core.install.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# UCrop (Image Cropper)
-keep class com.yalantis.ucrop.** { *; }

# Firebase
-dontwarn com.google.firebase.**
-keep class com.google.firebase.** { *; }

# Google Play Services & Maps
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Preserve annotations and signatures
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Suppress warnings from common libraries
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.bouncycastle.**
