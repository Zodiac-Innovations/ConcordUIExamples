package com.zodiacinnovations.venueshowcase

import android.content.Context
import android.content.res.Configuration
import android.os.Build
import java.util.Locale
import java.util.TimeZone

/** Native Android application, platform, device, and regional information. */
object ConcordPlatformInformation {
    private lateinit var applicationContext: Context

    @JvmStatic
    fun initialize(context: Context) {
        applicationContext = context.applicationContext
    }

    @JvmStatic
    fun appName(): String = runCatching {
        val info = applicationContext.applicationInfo
        applicationContext.packageManager.getApplicationLabel(info).toString()
    }.getOrDefault("Application")

    @JvmStatic
    fun appIdentifier(): String =
        if (::applicationContext.isInitialized) applicationContext.packageName else ""

    @Suppress("DEPRECATION")
    private fun packageInfo() =
        applicationContext.packageManager.getPackageInfo(applicationContext.packageName, 0)

    @JvmStatic
    fun appVersion(): String = runCatching {
        packageInfo().versionName ?: "0.0"
    }.getOrDefault("0.0")

    @JvmStatic
    fun appBuild(): String = runCatching {
        val info = packageInfo()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) info.longVersionCode.toString()
        else info.versionCode.toString()
    }.getOrDefault("0")

    @JvmStatic
    fun appCopyright(): String? = runCatching {
        applicationContext.getString(R.string.app_copyright).takeIf { it.isNotBlank() }
    }.getOrNull()

    @JvmStatic
    fun platformName(): String = "Android"

    @JvmStatic
    fun platformType(): String = "android"

    @JvmStatic
    fun platformVersion(): String = Build.VERSION.RELEASE.ifBlank { "Unknown" }

    @JvmStatic
    fun platformAPILevel(): String = Build.VERSION.SDK_INT.toString()

    @JvmStatic
    fun deviceModel(): String = Build.MODEL.ifBlank { "Unknown" }

    @JvmStatic
    fun deviceManufacturer(): String = Build.MANUFACTURER.ifBlank { "Unknown" }

    @JvmStatic
    fun localeIdentifier(): String {
        val locale = currentLocale()
        return locale.toLanguageTag().ifBlank { locale.toString() }.ifBlank { "Unknown" }
    }

    @JvmStatic
    fun languageCode(): String = currentLocale().language.ifBlank { "Unknown" }

    @JvmStatic
    fun timeZoneIdentifier(): String = TimeZone.getDefault().id.ifBlank { "Unknown" }

    @JvmStatic
    fun appearanceMode(): String {
        if (!::applicationContext.isInitialized) return "Unknown"
        return when (applicationContext.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) {
            Configuration.UI_MODE_NIGHT_YES -> "Dark"
            Configuration.UI_MODE_NIGHT_NO -> "Light"
            else -> "Unspecified"
        }
    }

    @JvmStatic
    fun deviceClass(): String {
        if (!::applicationContext.isInitialized) return "Unknown"
        val configuration = applicationContext.resources.configuration
        if (configuration.smallestScreenWidthDp >= 600) return "Tablet"
        return when (configuration.screenLayout and Configuration.SCREENLAYOUT_SIZE_MASK) {
            Configuration.SCREENLAYOUT_SIZE_LARGE,
            Configuration.SCREENLAYOUT_SIZE_XLARGE -> "Tablet"
            else -> "Phone"
        }
    }

    @JvmStatic
    fun deviceType(): String {
        if (!::applicationContext.isInitialized) return "unknown"
        return if (applicationContext.resources.configuration.smallestScreenWidthDp >= 600) "pad" else "mobile"
    }

    @JvmStatic
    fun orientation(): String {
        if (!::applicationContext.isInitialized) return "none"
        return when (applicationContext.resources.configuration.orientation) {
            Configuration.ORIENTATION_LANDSCAPE -> "landscape"
            Configuration.ORIENTATION_PORTRAIT -> "portrait"
            else -> "none"
        }
    }

    private fun currentLocale(): Locale {
        if (!::applicationContext.isInitialized) return Locale.getDefault()
        val locales = applicationContext.resources.configuration.locales
        return if (!locales.isEmpty) locales[0] else Locale.getDefault()
    }
}