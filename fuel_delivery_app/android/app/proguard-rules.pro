# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in AIDL files and Gradle build type configurations.
# In most cases, you should not modify the following rules. 
# They are automatically generated and updated by the Android Gradle plugin.

# Keep rules for Stripe classes to prevent R8 from removing them
-dontwarn com.stripe.**
-keep class com.stripe.** { *; }
-keep class com.reactnativestripesdk.** { *; }


