# Keep rules for plugins that use reflection or native callbacks. Without
# these, R8 strips classes that are referenced only from JNI / Parcelable /
# BiometricPrompt, and the release build crashes when the path is exercised.

# flutter_secure_storage — EncryptedSharedPreferences + Tink ciphers loaded
# reflectively at runtime.
-keep class androidx.security.crypto.** { *; }
-keep class com.google.crypto.tink.** { *; }

# local_auth — BiometricPrompt authentication callbacks.
-keep class androidx.biometric.** { *; }
-keep class io.flutter.plugins.localauth.** { *; }

# nfc_manager — Android NFC stack uses Parcelable + reflection for tag
# dispatch.
-keep class android.nfc.** { *; }
-keep class io.flutter.plugins.nfc_manager.** { *; }

# mobile_scanner / zxing — barcode format enumeration via reflection.
-keep class com.google.zxing.** { *; }
-keep class io.github.julian-arroyo.mobile_scanner.** { *; }

# flutter_local_notifications — GSON (de)serialises notification/schedule models
# reflectively; keep them and the plugin classes.
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# workmanager — the background Dart callback dispatcher is invoked via the
# WorkManager Worker; keep the plugin + androidx.work classes.
-keep class dev.fluttercommunity.workmanager.** { *; }
-keep class androidx.work.** { *; }

# Generic safety net — Flutter plugins commonly enumerate enum values via
# reflection across the JNI boundary.
-keepclassmembers enum * { *; }
