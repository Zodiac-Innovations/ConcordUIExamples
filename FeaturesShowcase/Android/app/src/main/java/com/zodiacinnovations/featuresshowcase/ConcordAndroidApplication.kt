package com.zodiacinnovations.featuresshowcase

import android.app.Application

/** Initializes native Android services used by ConcordPlatform. */
class ConcordAndroidApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        ConcordPlatformInformation.initialize(this)
        ConcordSecureStorage.initialize(this)
        ConcordPlatformActions.initialize(this)
        ConcordResourceManager.initialize(this)
        ConcordPrintManager.initialize(this)
        ConcordAudioManager.initialize(this)
        ConcordBannerManager.initialize(this)
        ConcordNative.setPlatformEnvironment()
        ConcordNative.setBannerEnvironment()
    }
}