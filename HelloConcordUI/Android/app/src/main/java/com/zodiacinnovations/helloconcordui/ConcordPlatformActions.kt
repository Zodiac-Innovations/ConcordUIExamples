package com.zodiacinnovations.helloconcordui

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings

/** Native Android implementation backing ConcordUI external platform actions. */
object ConcordPlatformActions {
    private lateinit var applicationContext: Context

    @JvmStatic
    fun initialize(context: Context) {
        applicationContext = context.applicationContext
    }

    @JvmStatic
    fun canLaunch(uri: String): Boolean = runCatching {
        check(::applicationContext.isInitialized)
        Intent(Intent.ACTION_VIEW, Uri.parse(uri))
            .resolveActivity(applicationContext.packageManager) != null
    }.getOrDefault(false)

    @JvmStatic
    fun launch(uri: String): Boolean = runCatching {
        check(::applicationContext.isInitialized)
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(uri)).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        if (intent.resolveActivity(applicationContext.packageManager) == null) return false
        applicationContext.startActivity(intent)
        true
    }.getOrDefault(false)

    @JvmStatic
    fun canOpenSettings(): Boolean = runCatching {
        check(::applicationContext.isInitialized)
        val intent = Intent(
            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
            Uri.parse("package:${applicationContext.packageName}")
        )
        intent.resolveActivity(applicationContext.packageManager) != null
    }.getOrDefault(false)

    @JvmStatic
    fun openSettings(): Boolean = runCatching {
        check(::applicationContext.isInitialized)
        val intent = Intent(
            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
            Uri.parse("package:${applicationContext.packageName}")
        ).apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }
        if (intent.resolveActivity(applicationContext.packageManager) == null) return false
        applicationContext.startActivity(intent)
        true
    }.getOrDefault(false)
}