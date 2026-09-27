package com.zodiacinnovations.elementshowcase

import android.content.Context
import android.content.Intent
import android.webkit.MimeTypeMap
import androidx.core.content.FileProvider
import java.io.File

/** Locates packaged ConcordUI resources and opens copies through secure content URIs. */
object ConcordResourceManager {
    private lateinit var applicationContext: Context

    @JvmStatic
    fun initialize(context: Context) {
        applicationContext = context.applicationContext
    }

    @JvmStatic
    fun exists(name: String, type: String): Boolean =
        findAsset(name, type) != null

    @JvmStatic
    fun retrieve(name: String, type: String): String = runCatching {
        val path = findAsset(name, type) ?: return ""
        android.util.Base64.encodeToString(
            applicationContext.assets.open(path).use { it.readBytes() },
            android.util.Base64.NO_WRAP
        )
    }.getOrDefault("")

    @JvmStatic
    fun open(name: String, type: String): Boolean = runCatching {
        check(::applicationContext.isInitialized)
        val assetPath = findAsset(name, type) ?: return false
        val outputDirectory = File(applicationContext.cacheDir, "concord-resources")
        outputDirectory.mkdirs()
        val output = File(outputDirectory, assetPath.substringAfterLast('/'))
        applicationContext.assets.open(assetPath).use { input ->
            output.outputStream().use { input.copyTo(it) }
        }

        val uri = FileProvider.getUriForFile(
            applicationContext,
            "${applicationContext.packageName}.concordui.resources",
            output
        )
        val mimeType = MimeTypeMap.getSingleton()
            .getMimeTypeFromExtension(output.extension.lowercase())
            ?: "application/octet-stream"
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, mimeType)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        if (intent.resolveActivity(applicationContext.packageManager) == null) return false
        applicationContext.startActivity(intent)
        true
    }.getOrDefault(false)

    private fun findAsset(name: String, type: String): String? {
        if (!::applicationContext.isInitialized || !validName(name)) return null
        return candidates(name, type).firstOrNull { path ->
            runCatching {
                applicationContext.assets.open(path).use { }
                true
            }.getOrDefault(false)
        }
    }

    private fun candidates(name: String, type: String): List<String> = when {
        type == "text" -> listOf(
            "$name.txt",
            "Text/$name.txt",
            "Document/$name.txt",
            "Documents/$name.txt"
        )
        type == "pdf" -> listOf(
            "$name.pdf",
            "Document/$name.pdf",
            "Documents/$name.pdf"
        )
        type == "image" -> listOf(
            "$name.png",
            "$name.jpeg",
            "$name.jpg",
            "Image/$name.png",
            "Image/$name.jpeg",
            "Image/$name.jpg",
            "Images/$name.png",
            "Images/$name.jpeg",
            "Images/$name.jpg"
        )
        type.startsWith("custom:") -> {
            val extension = type.substringAfter("custom:").trim().trimStart('.').lowercase()
            if (extension.isEmpty()) emptyList() else listOf(
                "$name.$extension",
                "Document/$name.$extension",
                "Documents/$name.$extension",
                "Image/$name.$extension",
                "Images/$name.$extension",
                "Text/$name.$extension"
            )
        }
        else -> emptyList()
    }

    private fun validName(name: String): Boolean =
        name.isNotBlank() && !name.contains('/') && !name.contains('\\')

    @JvmStatic
    fun canShare(): Boolean = ::applicationContext.isInitialized

    @JvmStatic
    fun share(name: String, type: String): Boolean = runCatching {
        val assetPath = findAsset(name, type) ?: return false
        val outputDirectory = File(applicationContext.cacheDir, "concord-resources")
        outputDirectory.mkdirs()
        val output = File(outputDirectory, assetPath.substringAfterLast('/'))
        applicationContext.assets.open(assetPath).use { input ->
            output.outputStream().use { input.copyTo(it) }
        }
        shareFile(output, MimeTypeMap.getSingleton()
            .getMimeTypeFromExtension(output.extension.lowercase())
            ?: "application/octet-stream")
    }.getOrDefault(false)

    @JvmStatic
    fun shareText(text: String): Boolean = runCatching {
        check(::applicationContext.isInitialized)
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, text)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        applicationContext.startActivity(
            Intent.createChooser(intent, null).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        )
        true
    }.getOrDefault(false)

    @JvmStatic
    fun shareData(encoded: String, filename: String, mimeType: String): Boolean = runCatching {
        check(::applicationContext.isInitialized)
        if (filename.isBlank() || filename.contains('/') || filename.contains('\\')) return false
        val bytes = android.util.Base64.decode(encoded, android.util.Base64.NO_WRAP)
        val outputDirectory = File(applicationContext.cacheDir, "concord-resources")
        outputDirectory.mkdirs()
        val output = File(outputDirectory, filename)
        output.writeBytes(bytes)
        shareFile(output, mimeType.ifBlank { "application/octet-stream" })
    }.getOrDefault(false)

    private fun shareFile(file: File, mimeType: String): Boolean {
        val uri = FileProvider.getUriForFile(
            applicationContext,
            "${applicationContext.packageName}.concordui.resources",
            file
        )
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = mimeType
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        applicationContext.startActivity(
            Intent.createChooser(intent, null).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        )
        return true
    }}