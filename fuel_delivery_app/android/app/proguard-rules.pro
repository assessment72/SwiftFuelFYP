# Ignore missing Stripe Push Provisioning classes if not used
-dontwarn com.stripe.android.pushProvisioning.**
-dontwarn com.reactnativestripesdk.pushprovisioning.**

# General keep rules (optional but useful)
-keep class com.stripe.** { *; }
-keep class com.reactnativestripesdk.** { *; }
-keepclassmembers class * {
    public <init>(...);
}
