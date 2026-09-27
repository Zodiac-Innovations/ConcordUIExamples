package com.zodiacinnovations.featuresshowcase

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/** Native Android implementation backing ConcordUI secure storage. */
object ConcordSecureStorage {
    private const val KEY_ALIAS = "ConcordUI.SecureStorage.Key"
    private const val PREFERENCES = "ConcordUI.SecureStorage"
    private const val ANDROID_KEY_STORE = "AndroidKeyStore"
    private const val TRANSFORMATION = "AES/GCM/NoPadding"

    private lateinit var applicationContext: Context

    @JvmStatic
    fun initialize(context: Context) {
        applicationContext = context.applicationContext
    }

    @JvmStatic
    fun set(key: String, value: String): Boolean = runCatching {
        check(::applicationContext.isInitialized)
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, secretKey())
        val encrypted = cipher.doFinal(Base64.decode(value, Base64.NO_WRAP))
        val stored = Base64.encodeToString(cipher.iv + encrypted, Base64.NO_WRAP)
        applicationContext.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .edit()
            .putString(key, stored)
            .commit()
    }.getOrDefault(false)

    @JvmStatic
    fun get(key: String): String = runCatching {
        check(::applicationContext.isInitialized)
        val stored = applicationContext.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .getString(key, null) ?: return ""
        val combined = Base64.decode(stored, Base64.NO_WRAP)
        if (combined.size <= 12) return ""
        val iv = combined.copyOfRange(0, 12)
        val encrypted = combined.copyOfRange(12, combined.size)
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.DECRYPT_MODE, secretKey(), GCMParameterSpec(128, iv))
        Base64.encodeToString(cipher.doFinal(encrypted), Base64.NO_WRAP)
    }.getOrDefault("")

    @JvmStatic
    fun remove(key: String): Boolean = runCatching {
        check(::applicationContext.isInitialized)
        applicationContext.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .edit()
            .remove(key)
            .commit()
    }.getOrDefault(false)

    private fun secretKey(): SecretKey {
        val keyStore = KeyStore.getInstance(ANDROID_KEY_STORE).apply { load(null) }
        (keyStore.getKey(KEY_ALIAS, null) as? SecretKey)?.let { return it }

        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEY_STORE)
        generator.init(
            KeyGenParameterSpec.Builder(
                KEY_ALIAS,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setKeySize(256)
                .build()
        )
        return generator.generateKey()
    }
}