# EzyBill — R8 rules for release builds.
#
# R8 already applies these automatically:
#   1. Android's default rules (proguard-android-optimize.txt)
#   2. Flutter's own rules (added by the Flutter Gradle plugin)
#   3. Each plugin's own bundled rules
# This file only adds what EzyBill wants on top of them.
#
# Add a -keep rule ONLY when a release build proves it is needed (for example
# a crash naming a specific class), and write down why next to it.

# 1. Remove Android debug/verbose/info log calls from the Java/Kotlin code
#    (plugins and MainActivity) in release builds. Warnings and errors stay.
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
}

# 2. Keep line numbers so crash reports stay readable (together with
#    mapping.txt), but hide the real source file names.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
