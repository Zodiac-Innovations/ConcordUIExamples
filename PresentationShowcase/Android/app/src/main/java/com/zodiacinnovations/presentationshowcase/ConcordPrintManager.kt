package com.zodiacinnovations.presentationshowcase

import android.app.Activity
import android.app.Application
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.Typeface
import android.os.Bundle
import android.os.CancellationSignal
import android.os.ParcelFileDescriptor
import android.print.PageRange
import android.print.PrintAttributes
import android.print.PrintDocumentAdapter
import android.print.PrintDocumentInfo
import android.print.PrintManager
import android.print.pdf.PrintedPdfDocument
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import android.util.Base64
import java.io.FileOutputStream
import kotlin.math.ceil
import kotlin.math.min

/** Native Android implementation backing ConcordUI text and bitmap printing. */
object ConcordPrintManager : Application.ActivityLifecycleCallbacks {
    private var application: Application? = null
    private var currentActivity: Activity? = null

    @JvmStatic
    fun initialize(context: Context) {
        val app = context.applicationContext as? Application ?: return
        if (application === app) return
        application?.unregisterActivityLifecycleCallbacks(this)
        application = app
        app.registerActivityLifecycleCallbacks(this)
    }

    @JvmStatic
    fun canPrint(): Boolean = currentActivity != null

    @JvmStatic
    fun printText(text: String, font: String): Boolean = runCatching {
        val activity = currentActivity ?: return false
        val manager = activity.getSystemService(Context.PRINT_SERVICE) as? PrintManager ?: return false
        manager.print("ConcordUI Text", TextAdapter(activity, text, font == "monospaced"), null)
        true
    }.getOrDefault(false)

    @JvmStatic
    fun printImage(encoded: String, size: String): Boolean = runCatching {
        val activity = currentActivity ?: return false
        val bytes = Base64.decode(encoded, Base64.NO_WRAP)
        val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size) ?: return false
        val manager = activity.getSystemService(Context.PRINT_SERVICE) as? PrintManager ?: return false
        manager.print("ConcordUI Image", ImageAdapter(activity, bitmap, size == "true"), null)
        true
    }.getOrDefault(false)

    override fun onActivityCreated(activity: Activity, state: Bundle?) { currentActivity = activity }
    override fun onActivityStarted(activity: Activity) { currentActivity = activity }
    override fun onActivityResumed(activity: Activity) { currentActivity = activity }
    override fun onActivityPaused(activity: Activity) = Unit
    override fun onActivityStopped(activity: Activity) = Unit
    override fun onActivitySaveInstanceState(activity: Activity, state: Bundle) = Unit
    override fun onActivityDestroyed(activity: Activity) {
        if (currentActivity === activity) currentActivity = null
    }

    private class TextAdapter(
        private val context: Context,
        private val text: String,
        private val monospaced: Boolean
    ) : PrintDocumentAdapter() {
        private var attributes = PrintAttributes.Builder().build()

        override fun onLayout(
            oldAttributes: PrintAttributes?,
            newAttributes: PrintAttributes,
            cancellationSignal: CancellationSignal,
            callback: LayoutResultCallback,
            extras: Bundle?
        ) {
            if (cancellationSignal.isCanceled) {
                callback.onLayoutCancelled()
                return
            }
            attributes = newAttributes
            callback.onLayoutFinished(
                PrintDocumentInfo.Builder("ConcordUI-Text.txt")
                    .setContentType(PrintDocumentInfo.CONTENT_TYPE_DOCUMENT)
                    .setPageCount(PrintDocumentInfo.PAGE_COUNT_UNKNOWN)
                    .build(),
                true
            )
        }

        override fun onWrite(
            pages: Array<PageRange>,
            destination: ParcelFileDescriptor,
            cancellationSignal: CancellationSignal,
            callback: WriteResultCallback
        ) {
            val content = printableRect(context, attributes)
            val document = PrintedPdfDocument(context, attributes)
            try {
                val paint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
                    textSize = 12f
                    typeface = if (monospaced) Typeface.MONOSPACE else Typeface.DEFAULT
                }
                val width = content.width().coerceAtLeast(1)
                val height = content.height().coerceAtLeast(1)
                val layout = StaticLayout.Builder
                    .obtain(text, 0, text.length, paint, width)
                    .setAlignment(Layout.Alignment.ALIGN_NORMAL)
                    .setIncludePad(true)
                    .build()
                val pageCount = maxOf(1, ceil(layout.height.toDouble() / height.toDouble()).toInt())
                val written = mutableListOf<PageRange>()

                for (pageIndex in 0 until pageCount) {
                    if (cancellationSignal.isCanceled) {
                        callback.onWriteCancelled()
                        return
                    }
                    if (!containsPage(pages, pageIndex)) continue
                    val page = document.startPage(pageIndex)
                    val canvas = page.canvas
                    val rect = page.info.contentRect
                    canvas.save()
                    canvas.clipRect(rect)
                    canvas.translate(rect.left.toFloat(), (rect.top - pageIndex * rect.height()).toFloat())
                    layout.draw(canvas)
                    canvas.restore()
                    document.finishPage(page)
                    written.add(PageRange(pageIndex, pageIndex))
                }
                FileOutputStream(destination.fileDescriptor).use { document.writeTo(it) }
                callback.onWriteFinished(written.toTypedArray())
            } catch (error: Throwable) {
                callback.onWriteFailed(error.localizedMessage)
            } finally {
                document.close()
            }
        }
    }

    private class ImageAdapter(
        private val context: Context,
        private val bitmap: Bitmap,
        private val sizeToFit: Boolean
    ) : PrintDocumentAdapter() {
        private var attributes = PrintAttributes.Builder().build()

        override fun onLayout(
            oldAttributes: PrintAttributes?,
            newAttributes: PrintAttributes,
            cancellationSignal: CancellationSignal,
            callback: LayoutResultCallback,
            extras: Bundle?
        ) {
            if (cancellationSignal.isCanceled) {
                callback.onLayoutCancelled()
                return
            }
            attributes = newAttributes
            callback.onLayoutFinished(
                PrintDocumentInfo.Builder("ConcordUI-Image")
                    .setContentType(PrintDocumentInfo.CONTENT_TYPE_PHOTO)
                    .setPageCount(1)
                    .build(),
                true
            )
        }

        override fun onWrite(
            pages: Array<PageRange>,
            destination: ParcelFileDescriptor,
            cancellationSignal: CancellationSignal,
            callback: WriteResultCallback
        ) {
            if (!containsPage(pages, 0)) {
                callback.onWriteFinished(emptyArray())
                return
            }
            val document = PrintedPdfDocument(context, attributes)
            try {
                if (cancellationSignal.isCanceled) {
                    callback.onWriteCancelled()
                    return
                }
                val page = document.startPage(0)
                val rect = page.info.contentRect
                val scale = if (sizeToFit) {
                    min(
                        rect.width().toFloat() / bitmap.width.toFloat(),
                        rect.height().toFloat() / bitmap.height.toFloat()
                    )
                } else 1f
                val width = bitmap.width * scale
                val height = bitmap.height * scale
                val x = if (sizeToFit) rect.left + (rect.width() - width) / 2f else rect.left.toFloat()
                val y = if (sizeToFit) rect.top + (rect.height() - height) / 2f else rect.top.toFloat()
                val matrix = Matrix().apply {
                    postScale(scale, scale)
                    postTranslate(x, y)
                }
                page.canvas.save()
                page.canvas.clipRect(rect)
                page.canvas.drawBitmap(bitmap, matrix, Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG))
                page.canvas.restore()
                document.finishPage(page)
                FileOutputStream(destination.fileDescriptor).use { document.writeTo(it) }
                callback.onWriteFinished(arrayOf(PageRange(0, 0)))
            } catch (error: Throwable) {
                callback.onWriteFailed(error.localizedMessage)
            } finally {
                document.close()
            }
        }
    }

    private fun printableRect(context: Context, attributes: PrintAttributes): Rect {
        val measure = PrintedPdfDocument(context, attributes)
        return try {
            val page = measure.startPage(0)
            val rect = Rect(page.info.contentRect)
            measure.finishPage(page)
            rect
        } finally {
            measure.close()
        }
    }

    private fun containsPage(ranges: Array<PageRange>, page: Int): Boolean =
        ranges.any { range -> range == PageRange.ALL_PAGES || page in range.start..range.end }
}